package route;

import Error;
import mweb.http.*;
import mweb.http.Status;
import mweb.tools.*;

@:includeTemplate("register.html")
class RegisterView extends BaseView<{ email:String, name:String, msg:String }> {
}

class Register extends BaseRoute {
	var view:RegisterView;

	function respond(postArgs, status, msg)
	{
		var data = { email : postArgs.email, name : postArgs.name, msg : msg };
		return Response.fromContent(new TemplateLink(data, view)).setStatus(status);
	}

	@openRoute @login
	public function get():Response<{ email:String, msg:String }>
	{
		if (loop.session.isAuthenticated())
			return new Response().redirect("/");
		return respond(cast {}, OK, null);
	}

	@openRoute @login
	public function post(args:{ email:String, name:String, pass:String }):Response<Dynamic>
	{
		try {
			Auth.register(_ctx, args.email, args.name, args.pass);
			return new route.Login(_ctx).post(args);  // TODO don't use new instance of Login
		} catch (err:AuthenticationError) {
			return switch (err) {
				case EInvalidEmail: respond(args, BadRequest, "Invalid email");
				case EInvalidName: respond(args, BadRequest, "Please use a name between 1 and 32 characters long");
				case EInvalidPass: respond(args, BadRequest, "Invalid password: must have between 6 and 64 characters");
				case EUserAlreadyExists: respond(args, Conflict, "Email already registred");
				case EFailedLogin: respond(args, InternalServerError, "");  // should not reach here
			}
		}
	}

	public function new(ctx)
	{
		super(ctx);
		view = new RegisterView(ctx);
	}
}

