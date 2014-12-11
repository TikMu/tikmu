package dispatch;
import croxit.Web;

class Dispatcher
{

	public static function dispatch()
	{
		var d = new haxe.web.Dispatch(Web.getURI(), Web.getParams());
		var x = 10, y = 20;
		if (x == 10) {
			var tmp = x;
			x = y;
			y = tmp;
		}
		// d.dispatch(
	}

}
