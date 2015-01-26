package routes;
import mweb.tools.*;

class BaseRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:db.Context;
	public function new(ctx:db.Context)
	{
		super();
		this.ctx = ctx;
	}
}
