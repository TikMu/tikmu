package dispatch;
import mweb.tools.*;

class RegisterRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:db.Context;
	public function new(ctx:db.Context)
	{
		super();
		this.ctx = ctx;
	}

	public function getDefault(?args:{ msg: String }):HttpResponse<{ message:String }>
	{
		trace('//TODO');
		return null;
	}

	public function postDefault(args:{ user:String, pass:String }):HttpResponse<Dynamic>
	{
		trace('//TODO');
		return null;
	}
}
