import Error;
import croxit.Web;
import db.*;
import mweb.Dispatcher;
import mweb.tools.*;
import org.mongodb.Mongo;
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

	static function main()
	{
		// init log (and trace)
		haxe.Log.trace = function (msg, ?p) {
			var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
			Sys.stderr().writeString(s);
		}

		// init mongo
		var mongo = new Mongo();
		var ctx = new db.Context(mongo.tikmu);

		// handle session
		var cookies = Web.getCookies();
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

		// init mweb
		var d = new Dispatcher(Web);
		d.addMetaHandler(handleLoggedMeta.bind(ctx));
		var routes = mweb.Route.anon({
			// keep sorted
			anyDefault: @openRoute function(d:Dispatcher<Dynamic>) return d.getRoute(routes.list.ListRoute).anyDefault(),
			ask: new routes.ask.AskRoute(ctx),
			list: new routes.list.ListRoute(ctx),
			listfavorites: new routes.list.ListFavoritesRoute(ctx),
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

		// dispatch
		var ret:HttpResponse<Dynamic>;
		try {
			ret = d.dispatch(routes);
		} catch (e:AuthorizationError) {
			trace(e);
			ret = HttpResponse.empty().redirect('/login');
		}

		// setCookie updated _session, if necessary
		if (cookies.get("_session") != ctx.session._id)
			ret.setCookie("_session", ctx.session._id);
		else if (!ctx.session.isValid())
			ret.setCookie("_session", "");

		// response
		HttpWriter.fromWeb(Web).writeResponse(ret);
	}
}
