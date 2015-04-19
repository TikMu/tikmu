package routes.login;

import db.*;
import mweb.tools.*;

class LogOutRoute extends BaseRoute
{
	public function any():HttpResponse<Void>
	{
		loop.session.close();
		data.sessions.save(loop.session);
		return HttpResponse.empty().redirect("/");
	}
}

