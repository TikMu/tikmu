package dispatch;
import mweb.tools.*;

class LoginRoute extends mweb.Route<HttpResponse<Dynamic>>
{
	var ctx:db.Context;
	public function new(ctx:db.Context)
	{
		super();
		this.ctx = ctx;
	}

	public function getDefault(?args:{ msg: String }):HttpResponse<{ msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args == null ? { msg: null } : args, new LoginView()));
	}

	public function postDefault(args:{ user:String, pass:String }):HttpResponse<Dynamic>
	{
		return HttpResponse.empty().redirect('/');
	}
}

@:includeTemplate("../views/login.html")
class LoginView extends erazor.macro.SimpleTemplate<{ msg:String }>
{
}
