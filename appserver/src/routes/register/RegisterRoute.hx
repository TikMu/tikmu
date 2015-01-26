package routes.register;
import mweb.tools.*;

class RegisterRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:db.Context;
	public function new(ctx:db.Context)
	{
		super();
		this.ctx = ctx;
	}

	@openRoute
	public function getDefault(?args:{ msg: String }):HttpResponse<{ message:String }>
	{
		trace('//TODO');
		return null;
	}

	@openRoute
	public function postDefault(args:{ user:String, pass:String }):HttpResponse<Dynamic>
	{
		trace('//TODO');
		return null;
	}
}
