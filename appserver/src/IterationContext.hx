import Error;
import db.*;
import mweb.*;
import mweb.tools.*;
using Lambda;

class IterationContext {
	var routeMap:Route<Dynamic>;

	@:allow(Context)
	@:allow(route.Login)
	public var session(default,null):Session;

	public var now(default,null):Date;

	function handleLoggedMeta(metas:Array<String>)
	{
		var noAuth = #if tikmu_require_login "login" #else "openRoute" #end;
		if (metas.has(noAuth))
			return;

		var s = session;
		if (!s.isValid())
			throw ExpiredSession(s);
		else if (!s.isAuthenticated())
			throw NotLogged;
	}

	@:allow(Context)
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

	public function new(routeMap)
	{
		this.routeMap = routeMap;

		session = null;
		now = Date.now();
	}
}

