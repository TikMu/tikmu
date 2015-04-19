import mweb.tools.*;

class BaseRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:Context;
	public function new(ctx:Context)
	{
		super();
		this.ctx = ctx;
	}
}

