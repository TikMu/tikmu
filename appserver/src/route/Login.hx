package route;

import db.*;
import mweb.tools.*;

@:includeTemplate("login.html")
class LoginView extends BaseView<{ msg:String }> {}

class Login extends BaseRoute {
	@openRoute
	public function get(?args:{ email:String, msg:String }):HttpResponse<{ msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args == null ? { msg: null } : args, new LoginView(_ctx)));
	}

	@openRoute
	public function post(args:{ email:String, pass:String }):HttpResponse<Dynamic>
	{
		// pre-validate args.email
		if (!Tools.validEmail(args.email))
			return get({ email : null, msg : "Invalid email" });

		// don't check for too long passwords
		if (args.pass.length > 256)  // FIXME no magic numbers
			return get({ email : args.email, msg : "Invalid password" });

		// authenticate
		var user = data.users.findOne({ email : args.email });
		if (user == null || !user.password.matches(args.pass))
			return get({ email : args.email, msg : "Wrong email address or password" });

		// set a session
		var s = new Session(null, user._id, 1e9, null);  // FIXME loc, device and real span
		data.sessions.save(s);
		loop.session = s;
		return HttpResponse.empty().redirect("/");
	}
}
