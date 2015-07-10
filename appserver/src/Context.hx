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

	@:allow(Main)
	function respond()  // TODO receive Request
	{
		trace('Request: ${Web.getMethod()} ${Web.getURI()}');
		trace('SessionCache usage: ${data.sessions.used} (capacity ${data.sessions.size})');

		loop = new IterationContext(routeMap);

		Auth.authorize(this);
		trace('Session: ${loop.session._id} (user=${loop.session.user})');

		var request = new mweb.http.webstd.Request();
		var response;
		try {
			response = loop.dispatch(request);
			Auth.sendSession(this, response);
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
