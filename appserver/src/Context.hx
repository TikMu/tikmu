import croxit.Web;
import mweb.*;
import mweb.tools.*;
import db.*;

class Context
{
	var routeMap:Route<Dynamic>;

	public var data(default,null):StorageContext;
	public var loop(default,null):IterationContext;

	@:allow(Main)
	function respond()  // TODO receice Web
	{
		var cookies = Web.getCookies();

		loop = new IterationContext(routeMap);

		// handle session
		if (cookies.exists("_session")) {
			var sid = cookies.get("_session");
			if (sid != "")
				loop.session = data.sessions.get(sid);
		}
		if (loop.session == null) {
			var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
			data.sessions.save(s);
			loop.session = s;
		}
		trace('Session: ${loop.session._id} (user=${loop.session.user})');

		var request = Web;
		var response = loop.dispatch(request);

		// setCookie updated _session, if necessary
		if (cookies.get("_session") != loop.session._id)
			response.setCookie("_session", loop.session._id);
		else if (!loop.session.isValid())
			response.setCookie("_session", "");

		HttpWriter.fromWeb(request).writeResponse(response);
	}

	public function new(db)
	{
		data = new StorageContext(db);

		routeMap = Route.anon({
			// keep each group sorted and keep the trailing commas

			// basic features
			answer : new route.Answer(this),
			ask: new route.Ask(this),
			comment : new route.Comment(this),
			favorites : new route.List.Favorites(this),
			list : new route.List(this),
			login: new route.Login(this),
			logout: new route.LogOut(this),
			question : new route.Question(this),
			register: new route.Register(this),
			search : new route.List.Search(this),
			user : new route.User(this),

			// aliases
			any : @openRoute function(d:Dispatcher<Dynamic>) return d.getRoute(route.List).any(),

			// old hackish api
			// TODO refactor
			// markquestionassolved : new routes.nonroute.NonRouteFunctions.MarkQuestionAsSolved(this),
			// voteup : new routes.nonroute.NonRouteFunctions.VoteUp(this),
			// votedown : new routes.nonroute.NonRouteFunctions.VoteDown(this),

			// helpers (but don't put anything sensitive here!)
			// FIXME don't forward them to the client anyway
			helper : Route.anon({
				menu: new route.helper.Menu(this),
			}),
		});
	}
}
