@:abstractTemplate
class BaseView<T> extends erazor.macro.SimpleTemplate<T> {
	var ctx:Context;

	public function new(ctx)
	{
		super();
		this.ctx = ctx;
	}
}

