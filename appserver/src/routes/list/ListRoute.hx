package routes.list;
import mweb.tools.*;

class ListRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:db.Context;
	public function new(ctx:db.Context)
	{
		super();
		this.ctx = ctx;
	}
}
