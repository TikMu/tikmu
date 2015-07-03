package route;

import mweb.http.*;
import mweb.tools.*;

class LogOut extends BaseRoute
{
	public function any():Response<Void>
	{
		loop.session.close();
		data.sessions.save(loop.session);
		return Response.empty().redirect("/");
	}
}

