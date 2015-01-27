package routes.register;

import crypto.Password;
import mweb.tools.*;
import org.bsonspec.ObjectID;

@:includeTemplate("register.html")
class RegisterView extends erazor.macro.SimpleTemplate<{ email:String, msg:String }> {
}

class RegisterRoute extends BaseRoute {
	@openRoute
	public function getDefault(?args:{ email:String, msg:String }):HttpResponse<{ email:String, msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args != null ? args : cast {}, new RegisterView()));
	}

	@openRoute
	public function postDefault(args:{ email:String, pass:String }):HttpResponse<Dynamic>
	{
		// validate args.user
		if (args.email.length < 1 || args.email.length > 64 || !~/.+@.+/.match(args.email))
			return HttpResponse.empty().redirect("/register?msg=Invalid email");

		// validate args.pass
		if (args.pass.length < 6 || args.pass.length > 64)
			return HttpResponse.empty().redirect('/register?email=${args.email}&msg=Passwords lenght must be between 6 and 64');
		// pre-check if a user already exists
		if (ctx.users.findOne({ email : args.email }) != null)
			return HttpResponse.empty().redirect('/register?msg=email ${args.email} already registred');

		// attempt to create the user
		var p = Password.create(args.pass);
		var u = {
			_id : new ObjectID(),
			name : 'User ${args.email}',
			email : args.email,
			password : p,
			avatar : null
		};
		ctx.users.insert(u);  // FIXME handle possible errors

		// TODO auto login

		return HttpResponse.empty().redirect("/");
	}
}

