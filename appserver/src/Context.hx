import croxit.Web;
import db.*;
import mweb.*;
import mweb.http.*;

class Context
{
	var routeMap:Route<Dynamic>;

	public var data(default,null):StorageContext;
	public var loop(default,null):IterationContext;
	public var aux(default,null):AuxiliaryContext;

	static function getCookies():Array<{key:String, val:String}>
	{
		var header = Web.getClientHeader("Cookie");
		var clean = ~/[\t\n ]+/.replace(header, "");
		var crumbs = clean.split(";").map(function (x) return x.split("="));
		var cookies = [for (c in crumbs) {
			key : StringTools.urlDecode(c[0]),
			val : StringTools.urlDecode(c[1])
		}];
		return cookies;
	}

	@:allow(Main)
	function respond()  // TODO receice Web
	{
		trace('Request: ${Web.getMethod()} ${Web.getURI()}');
		trace('SessionCache usage: ${data.sessions.used} (capacity ${data.sessions.size})');

		var cookies = getCookies();

		loop = new IterationContext(routeMap);

		// handle session
		var _sessions = Lambda.filter(cookies, function (x) return x.key == "_session");
		if (_sessions.length > 1)
			trace('WARNING: multiple _session cookies received ($_sessions)');
		if (_sessions.length == 1) {
			var sid = _sessions.first().val;
			if (sid != "")
				loop.session = data.sessions.get(sid);
		}
		if (loop.session == null) {
			var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
			data.sessions.save(s);
			loop.session = s;
		}
		trace('Session: ${loop.session._id} (user=${loop.session.user})');

		var request = new mweb.http.webstd.Request();
		var response;
		try {
			response = loop.dispatch(request);

			// try to gracefully fix multiple _session cookies on the client
			if (_sessions.length > 1)
				response.setCookie("_session", "");  // TODO fix multiple Set-Cookie in Web impl

			// set updated session cookie when necessary
			if (_sessions.first() == null || _sessions.first().val != loop.session._id)
				response.setCookie("_session", loop.session._id, ["path=/"]);
			else if (!loop.session.isValid())
				response.setCookie("_session", "", ["path=/"]);
		} catch (e:mweb.Errors.DispatcherError) {
			response = new Response().setStatus(NotFound);
		} catch (e:Dynamic) {
			trace('Exception: $e');
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			response = new Response().setStatus(InternalServerError);
		}

		var summary = switch (response.response) {
			case None, Content(_): 'status ' + (response.status != 0 ? '${response.status}' : '${Status.OK} (implicit)');
			case Redirect(to): 'redirect to $to';
		}
		trace('Response: $summary');
		new mweb.http.webstd.Writer().writeResponse(response);
	}

	public function new(db)
	{
		data = new StorageContext(db);
		aux = new AuxiliaryContext(this);

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
		});
	}
}
