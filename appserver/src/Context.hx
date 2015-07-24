import croxit.Web;
import db.*;
import haxe.Timer;
import mweb.*;
import mweb.http.*;

class Context {
	static var headerPxFilter = ["Authorization", "X-"];
	var routeMap:Route<Dynamic>;

	public var data(default,null):StorageContext;
	public var loop(default,null):IterationContext;
	public var aux(default,null):AuxiliaryContext;

	public var reputation(default,null):reputation.Handler;

	static function ms(s:Float)
	{
		return Std.int(s*1000);
	}

	@:allow(Main)
	function respond()  // TODO receive Request
	{
		var t0 = Timer.stamp();

		loop = new IterationContext(routeMap);

		trace('${Web.getMethod()} ${Web.getURI()}');
		trace('from ${Web.getClientIP()} at ${loop.now}');
		for (h in Web.getClientHeaders()) {
			if (Lambda.exists(headerPxFilter, function (x) return StringTools.startsWith(h.header, x)))
				trace('${h.header}: ${h.value}');
		}

		trace('session cache: ${data.sessions.used}/${data.sessions.size} slots in use');

		Auth.authorize(this);
		trace('session: ${loop.session._id} (user=${loop.session.user})');

		var request = new mweb.http.webstd.Request();
		var tinit = Timer.stamp();

		var response = loop.dispatch(request);

		if (!Lambda.exists(response.headers, function (x) return x.key == "Content-Type"))
			response.setHeader("Content-Type", "text/html");
		Auth.sendSession(this, response);
		if (response.status == 0)
			response.setStatus(OK);
		var tresponse = Timer.stamp();

		var summary = switch (response.response) {
			case None, Content(_): 'status ${response.status}';
			case Redirect(to): 'redirect to $to';
		}
		trace('returning $summary');

		new mweb.http.webstd.Writer().writeResponse(response);
		var tfinal = Timer.stamp();

		trace('spent ${ms(tfinal-t0)} ms in total: init=${ms(tinit-t0)} response=${ms(tresponse-tinit)} writing=${ms(tfinal-tresponse)}');
	}

	public function new(db)
	{
		data = new StorageContext(db);
		aux = new AuxiliaryContext(this);

		reputation = new reputation.Handler(this);

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
