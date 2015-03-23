package routes.login;

import db.*;
import db.helper.Ref.Ref;
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
		var user : User = this.ctx.users.findOne( { email : args.email } );	
		var refUser = (user != null && user.password.matches(args.pass)) ? new Ref<User>(user._id) : null;
				
		trace(refUser);
		
		// FIXME	
		var s = new Session(null, refUser, 1e9, null);
		ctx.sessions.save(s);
		return HttpResponse.empty().setCookie("_session", s._id).redirect("/");
	}
}

@:includeTemplate("login.html")
class LoginView extends erazor.macro.SimpleTemplate<{ msg:String }>
{
}
