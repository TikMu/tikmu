package route;

import mweb.http.*;
import mweb.tools.*;

class LogOut extends BaseRoute {
	@openRoute @login
	public function any():Response<Void>
	{
		Auth.logOut(_ctx);
		return Response.empty().redirect("/");
	}
}

