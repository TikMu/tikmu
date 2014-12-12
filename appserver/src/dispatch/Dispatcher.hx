package dispatch;
import croxit.Web;
import db.*;

class Dispatcher
{

	public static function dispatch()
	{
		var d = new haxe.web.Dispatch(Web.getURI(), Web.getParams());
		d.dispatch(new Dispatcher(Context.current));
	}

	public var ctx(default,null):Context;
	public function new(ctx:Context)
	{
		this.ctx = ctx;
	}

	@logged public function doDefault()
	{
		new Login(ctx).run();
	}
}
