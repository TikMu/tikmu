import Error;
import croxit.Web;
import db.*;
import mweb.*;
import mweb.tools.*;
import org.mongodb.*;
import routes.nonroute.*;
using Lambda;

class Context
{
	var db:Database;
	var routeMap:Route<Dynamic>;

	public var questions(default,null):Manager<Question>;
	public var sessions(default,null):SessionCache;
	public var users(default,null):Manager<User>;
	public var userQuestions(default,null):Manager<UserQuestions>;

	@:allow(routes.login.LoginRoute)
	public var session(default, null):Session;

	function handleLoggedMeta(metas:Array<String>)
	{
		// TODO: Change this test to handle sessions with no users
		// (for now, sessions are being created on logging in, so no sessions without users)
		// TODO does this still apply?
		if (!metas.has("openRoute"))
		{
			var s = session;
			if (!s.isValid())
				throw ExpiredSession(s);
			else if (!s.isAuthenticated())
				throw NotLogged;
		}
	}

	function dispatch(request:HttpRequest)
	{
		var d = new Dispatcher(request);
		d.addMetaHandler(handleLoggedMeta);
		var ret:HttpResponse<Dynamic>;
		try {
			ret = d.dispatch(routeMap);
		} catch (e:AuthorizationError) {
			trace(e);
			ret = HttpResponse.empty().redirect('/login');
		}

		return ret;
	}

	@:allow(Main)
	function respond()  // TODO receice Web
	{
		var cookies = Web.getCookies();

		// handle session
		session = null;
		if (cookies.exists("_session")) {
			var sid = cookies.get("_session");
			if (sid != "")
				session = sessions.get(sid);
		}
		if (session == null) {
			var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
			sessions.save(s);
			session = s;
		}
		trace('Session: ${session._id} (user=${session.user})');

		var request = Web;
		var response = dispatch(request);

		// setCookie updated _session, if necessary
		if (cookies.get("_session") != session._id)
			response.setCookie("_session", session._id);
		else if (!session.isValid())
			response.setCookie("_session", "");

		HttpWriter.fromWeb(request).writeResponse(response);
	}

	@:access(mweb.tools.HttpRequest) 
	function sub(url:String)
	{
		var method = "GET";
		var url = url.split("?");
		var uri = url[0];
		var params = new Map();
		HttpRequest.splitArgs(url[1], params);
		var request = HttpRequest.fromData(method, uri, params);
		return dispatch(request);
	}

	public function subHtml(url:String)
	{
		var res = sub(url);
		// FIXME reuse HttpWriter!
		return switch (res.response) {
		case Content(data):
			data.execute();
		case None:
			"";
		case Redirect(_):
			throw "Can't transform redirect into html";  // FIXME
		}
	}

	public function subValue(url:String)
	{
		var res = sub(url);
		return switch (res.response) {
		case Content(data):
			data.data;
		case None:
			null;
		case Redirect(_):
			throw "Can't transform redirect into value";  // FIXME
		}
	}

	public function new(db)
	{
		this.db = db;

		questions = new Manager<Question>(db.questions);
		sessions = new SessionCache(new Manager<Session>(db.sessions));
		users = new Manager<User>(db.users);
		userQuestions = new Manager<UserQuestions>(db.userquestions);

		routeMap = Route.anon({
			// keep sorted and keep trailing commas

			// basic features
			anyDefault: @openRoute function(d:Dispatcher<Dynamic>) return d.getRoute(routes.list.ListRoute).anyDefault(),
			ask: new routes.ask.AskRoute(this),
			list: new routes.list.ListRoute(this),
			login: new routes.login.LoginRoute(this),
			logout: new routes.login.LogOutRoute(this),
			question: new routes.question.QuestionRoute(this),
			register: new routes.register.RegisterRoute(this),
			search: new routes.search.SearchRoute(this),
			user : new route.User(this),

			// old hackish api
			// TODO refactor
			deleteanswer : new routes.nonroute.NonRouteFunctions.DeleteAnswer(this),
			deletecomment : new routes.nonroute.NonRouteFunctions.DeleteComment(this),
			editanswer : new routes.nonroute.NonRouteFunctions.EditAnswer(this),
			editcomment : new routes.nonroute.NonRouteFunctions.EditComment(this),
			editquestion : new routes.nonroute.NonRouteFunctions.EditQuestion(this),
			markquestionassolved : new routes.nonroute.NonRouteFunctions.MarkQuestionAsSolved(this),
			togglefavorite : new routes.nonroute.NonRouteFunctions.ToggleFavorite(this),
			togglefollow : new routes.nonroute.NonRouteFunctions.ToggleFollow(this),
			voteup : new routes.nonroute.NonRouteFunctions.VoteUp(this),
			votedown : new routes.nonroute.NonRouteFunctions.VoteDown(this),

			// helpers (but don't put anything sensitive here!)
			// FIXME don't forward them to the client anyway
			helper : Route.anon({
				menu: new route.helper.Menu(this),
			}),
		});

	}
}
