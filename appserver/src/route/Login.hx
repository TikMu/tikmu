package route;

import Error;
import mweb.http.*;
import mweb.http.Status;
import mweb.tools.*;

@:includeTemplate("login.html")
class LoginView extends BaseView<{ email:String, msg:String }> {}

class Login extends BaseRoute {
	var view:LoginView;

	function respond(postArgs, status, msg)
	{
		var data = { email : postArgs.email, msg : msg };
		return Response.fromContent(new TemplateLink(data, view)).setStatus(status);
	}

	@openRoute @login
	public function get(?args:{ email:String, msg:String }):Response<{ msg:String }>
	{
		if (loop.session.isAuthenticated())
			return new Response().redirect("/");
		return respond(cast {}, OK, null);
	}

	@openRoute @login
	public function post(args:{ email:String, pass:String }):Response<Dynamic>
	{
		try {
			Auth.login(_ctx, args.email, args.pass);
			return Response.empty().redirect("/");
		} catch (err:AuthenticationError) {
			return switch (err) {
				case EInvalidEmail: respond(args, BadRequest, "Invalid email");
				case EInvalidPass: respond(args, BadRequest, "Invalid password: must have between 6 and 64 characters");
				case EFailedLogin: respond(args, Forbidden, "Wrong email or password");
				case EInvalidName, EUserAlreadyExists: respond(args, InternalServerError, "");  // should not reach here
			}
		}
	}

	public function new(ctx)
	{
		super(ctx);
		view = new LoginView(ctx);
	}
}

