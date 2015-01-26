package routes.login;
import mweb.tools.*;

class LoginRoute extends BaseRoute
{
	@openRoute
	public function getDefault(?args:{ msg: String }):HttpResponse<{ msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args == null ? { msg: null } : args, new LoginView()));
	}

	@openRoute
	public function postDefault(args:{ user:String, pass:String }):HttpResponse<Dynamic>
	{
		return HttpResponse.empty().redirect('/');
	}
}

@:includeTemplate("login.html")
class LoginView extends erazor.macro.SimpleTemplate<{ msg:String }>
{
}
