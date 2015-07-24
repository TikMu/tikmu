import mweb.http.Response;
import mweb.tools.TemplateLink;

class BaseRoute extends mweb.Route<Response<Dynamic>> {
	@:skip public var _ctx:Context;
	@:skip public var data(get,never):StorageContext;
	@:skip public var loop(get,never):IterationContext;

	inline function get_data() return _ctx.data;
	inline function get_loop() return _ctx.loop;

	public function new(ctx:Context)
	{
		super();
		_ctx = ctx;
	}

	function json(data:Dynamic)
	{
		return haxe.Json.stringify(data);
	}

	function serialize(data:Dynamic)
	{
		return new Response().setHeader("Content-Type", "application/json").setContent(new TemplateLink(data, json));
	}
}

