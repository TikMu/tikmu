import Error;
import croxit.Web;
import db.*;
import mweb.Dispatcher;
import mweb.tools.*;
import org.mongodb.*;
import routes.nonroute.*;
using Lambda;

class Main
{
	var db:Database;
	var ctx:Context;

	function handleLoggedMeta(metas:Array<String>)
	{
		// TODO: Change this test to handle sessions with no users
		// (for now, sessions are being created on logging in, so no sessions without users)
		// TODO does this still apply?
		if (!metas.has("openRoute"))
		{
			var s = ctx.session;
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
		var routes = mweb.Route.anon({
			// keep sorted
			anyDefault: @openRoute function(d:Dispatcher<Dynamic>, ?args) return d.getRoute(routes.list.ListRoute).anyDefault(args),
			ask: new routes.ask.AskRoute(ctx),
			list: new routes.list.ListRoute(ctx),
			login: new routes.login.LoginRoute(ctx),
			logout: new routes.login.LogOutRoute(ctx),
			question: new routes.question.QuestionRoute(ctx),
			register: new routes.register.RegisterRoute(ctx),
			search: new routes.search.SearchRoute(ctx),

			// These will be changed to remoting functions (keep sorted too)
			deleteanswer : new routes.nonroute.NonRouteFunctions.DeleteAnswer(ctx),
			deletecomment : new routes.nonroute.NonRouteFunctions.DeleteComment(ctx),
			editanswer : new routes.nonroute.NonRouteFunctions.EditAnswer(ctx),
			editcomment : new routes.nonroute.NonRouteFunctions.EditComment(ctx),
			editquestion : new routes.nonroute.NonRouteFunctions.EditQuestion(ctx),
			markquestionassolved : new routes.nonroute.NonRouteFunctions.MarkQuestionAsSolved(ctx),
			togglefavorite : new routes.nonroute.NonRouteFunctions.ToggleFavorite(ctx),
			togglefollow : new routes.nonroute.NonRouteFunctions.ToggleFollow(ctx),
			voteup : new routes.nonroute.NonRouteFunctions.VoteUp(ctx),
			votedown : new routes.nonroute.NonRouteFunctions.VoteDown(ctx),
		});

		var ret:HttpResponse<Dynamic>;
		try {
			ret = d.dispatch(routes);
		} catch (e:AuthorizationError) {
			trace(e);
			ret = HttpResponse.empty().redirect('/login');
		}

		return ret;
	}

	@:access(mweb.tools.HttpRequest) 
	function subHtml(url:String)
	{
		var method = "GET";
		var url = url.split("?");
		var uri = url[0];
		var params = new Map();
		HttpRequest.splitArgs(url[1], params);
		var request = HttpRequest.fromData(method, uri, params);
		return dispatch(request);
	}

	function subValue(url:String)
	{
		var html = subHtml(url);
		return switch (html.response) {
		case Content(data):
			data.data;
		case None:
			null;
		case Redirect(_):
			throw "Can't transform redirect into value";
		}
	}

	function incoming()
	{
		var cookies = Web.getCookies();

		// handle session
		ctx.session = null;
		if (cookies.exists("_session")) {
			var sid = cookies.get("_session");
			if (sid != "")
				ctx.session = ctx.sessions.get(sid);
		}
		if (ctx.session == null) {
			var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
			ctx.sessions.save(s);
			ctx.session = s;
		}
		trace('Session: ${ctx.session._id} (user=${ctx.session.user})');

		var request = Web;
		var response = dispatch(request);

		// setCookie updated _session, if necessary
		if (cookies.get("_session") != ctx.session._id)
			response.setCookie("_session", ctx.session._id);
		else if (!ctx.session.isValid())
			response.setCookie("_session", "");

		HttpWriter.fromWeb(request).writeResponse(response);
	}

	function new(db)
	{
		this.db = db;
		ctx = new Context(db);
	}

	static function main()
	{
		haxe.Log.trace = function (msg, ?p) {
			var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
			Sys.stderr().writeString(s);
		}

		var mongo = new Mongo();
		var main = new Main(mongo.tikmu);

		/* TODO rinse and repeat */ {
			main.incoming();
		}
	}
}
