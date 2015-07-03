class BaseRoute extends mweb.Route<mweb.tools.HttpResponse<Dynamic>> {
	var _ctx:Context;
	var data(get,never):StorageContext;
	var loop(get,never):IterationContext;

	inline function get_data() return _ctx.data;
	inline function get_loop() return _ctx.loop;

	public function new(ctx:Context)
	{
		super();
		_ctx = ctx;
	}
}

