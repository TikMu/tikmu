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
	static function handleLoggedMeta(ctx:Context, metas:Array<String>)
	{
		// TODO: Change this test to handle sessions with no users
		// (for now, sessions are being created on logging in, so no sessions without users)
		if (!metas.has("openRoute"))
		{
			var s = ctx.session;
			if (!s.isValid())
				throw ExpiredSession(s);
			else if (!s.isAuthenticated())
				throw NotLogged;
		}
	}

	public static function dispatch(context:Context, request:HttpRequest)
	{
		var d = new Dispatcher(request);
		d.addMetaHandler(handleLoggedMeta.bind(context));
		var routes = mweb.Route.anon({
			// keep sorted
			anyDefault: @openRoute function(d:Dispatcher<Dynamic>, ?args) return d.getRoute(routes.list.ListRoute).anyDefault(args),
			ask: new routes.ask.AskRoute(context),
			list: new routes.list.ListRoute(context),
			login: new routes.login.LoginRoute(context),
			logout: new routes.login.LogOutRoute(context),
			question: new routes.question.QuestionRoute(context),
			register: new routes.register.RegisterRoute(context),
			search: new routes.search.SearchRoute(context),

			// These will be changed to remoting functions (keep sorted too)
			deleteanswer : new routes.nonroute.NonRouteFunctions.DeleteAnswer(context),
			deletecomment : new routes.nonroute.NonRouteFunctions.DeleteComment(context),
			editanswer : new routes.nonroute.NonRouteFunctions.EditAnswer(context),
			editcomment : new routes.nonroute.NonRouteFunctions.EditComment(context),
			editquestion : new routes.nonroute.NonRouteFunctions.EditQuestion(context),
			markquestionassolved : new routes.nonroute.NonRouteFunctions.MarkQuestionAsSolved(context),
			togglefavorite : new routes.nonroute.NonRouteFunctions.ToggleFavorite(context),
			togglefollow : new routes.nonroute.NonRouteFunctions.ToggleFollow(context),
			voteup : new routes.nonroute.NonRouteFunctions.VoteUp(context),
			votedown : new routes.nonroute.NonRouteFunctions.VoteDown(context),
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
	static function main()
	{
		haxe.Log.trace = function (msg, ?p) {
			var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
			Sys.stderr().writeString(s);
		}

		var mongo = new Mongo();
		var context = new Context(mongo.tikmu);

		var subHtml = function (url:String)
		{
			var method = "GET";
			var url = url.split("?");
			var uri = url[0];
			var data = url[1];
			var params = new Map();
			HttpRequest.splitArgs(data, params);
			var request = HttpRequest.fromData(method, uri, params);
			var response = dispatch(context, request);
			return response;
		}

		var subValue = function (url:String)
		{
			var response = subHtml(url);
			return switch (response.response) {
			case Content(data):
				data.data;
			case None:
				null;
			case all:
				throw "Can't transform a redirect into value";
			}
		}

		/* TODO rinse and repeat */ {
			var cookies = Web.getCookies();

			// handle session
			context.session = null;
			if (cookies.exists("_session")) {
				var sid = cookies.get("_session");
				if (sid != "")
					context.session = context.sessions.get(sid);
			}
			if (context.session == null) {
				var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
				context.sessions.save(s);
				context.session = s;
			}
			trace('Session: ${context.session._id} (user=${context.session.user})');

			var request = Web;
			var response = dispatch(context, request);

			// setCookie updated _session, if necessary
			if (cookies.get("_session") != context.session._id)
				response.setCookie("_session", context.session._id);
			else if (!context.session.isValid())
				response.setCookie("_session", "");

			HttpWriter.fromWeb(request).writeResponse(response);
		}
	}
}
