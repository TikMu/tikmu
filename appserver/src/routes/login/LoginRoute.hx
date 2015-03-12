package routes.login;
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
		if (!Tools.validEmail(args.email))
			return get({ email : null, msg : "Invalid email" });

		return HttpResponse.empty().redirect('/');
	}
}

@:includeTemplate("login.html")
class LoginView extends erazor.macro.SimpleTemplate<{ msg:String }>
{
}
