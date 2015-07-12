import Error;
import db.*;
import mweb.*;
import mweb.http.*;
import mweb.tools.*;
import crypto.Random;
using Lambda;

class IterationContext {
	var routeMap:Route<Dynamic>;

	@:allow(Context)
	@:allow(Auth)
	public var session(default,null):Session;

	public var now(default,null):Date;
	public var hash(default,null):String;

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
	function dispatch(request:Request)
	{
		var d = Dispatcher.createWithRequest(request);
		d.addMetaHandler(handleLoggedMeta);
		var ret:Response<Dynamic>;
		try {
			ret = d.dispatch(routeMap);
		} catch (e:AuthorizationError) {
			trace('authorization error: $e');
			ret = Response.empty().redirect('/login');
		}

		return ret;
	}

	public function new(routeMap)
	{
		this.routeMap = routeMap;

		session = null;
		now = Date.now();
		hash = Random.id(4);
	}
}

