package route;

import mweb.tools.*;

class LogOut extends BaseRoute
{
	public function any():HttpResponse<Void>
	{
		loop.session.close();
		data.sessions.save(loop.session);
		return HttpResponse.empty().redirect("/");
	}
}

