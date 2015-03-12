package routes.login;

import db.*;
import mweb.tools.*;

class LoginRoute extends BaseRoute
{
	@openRoute
	public function get(?args:{ email:String, msg:String }):HttpResponse<{ msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args == null ? { msg: null } : args, new LoginView()));
	}

	@openRoute
	public function post(args:{ email:String, pass:String }):HttpResponse<Dynamic>
	{
		// FIXME
		var s = new Session(null, null, 1e9, null);
		ctx.sessions.save(s);
		return HttpResponse.empty().setCookie("_session", s._id).redirect("/");
	}
}

@:includeTemplate("login.html")
class LoginView extends erazor.macro.SimpleTemplate<{ msg:String }>
{
}
