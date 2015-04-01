package routes.login;

import db.*;
import mweb.tools.*;

class LogOutRoute extends BaseRoute
{
	public function any():HttpResponse<Void>
	{
		ctx.session.close();
		ctx.sessions.save(ctx.session);
		return HttpResponse.empty().redirect("/");
	}
}

