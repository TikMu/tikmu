@:abstractTemplate
class BaseView<T> extends erazor.macro.SimpleTemplate<T> {
	var _ctx:Context;
	var loop(get,never):IterationContext;

	inline function get_loop() return _ctx.loop;

	public function new(ctx)
	{
		super();
		_ctx = ctx;
	}
}

