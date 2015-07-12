package route;

import mweb.http.*;
import mweb.tools.*;

class LogOut extends BaseRoute {
	public function any():Response<Void>
	{
		Auth.logOut(_ctx);
		return Response.empty().redirect("/");
	}
}

