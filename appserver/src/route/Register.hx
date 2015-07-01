package route;

import crypto.Password;
import mweb.tools.*;
import org.bsonspec.ObjectID;

@:includeTemplate("register.html")
class RegisterView extends BaseView<{ email:String, msg:String }> {
}

class Register extends BaseRoute {
	@openRoute @login
	public function get(?args:{ email:String, msg:String }):HttpResponse<{ email:String, msg:String }>
	{
		return HttpResponse.fromContent(new TemplateLink(args != null ? args : cast {}, new RegisterView(_ctx)));
	}

	@openRoute @login
	public function post(args:{ email:String, pass:String }):HttpResponse<Dynamic>
	{
		// validate args.email
		if (!Tools.validEmail(args.email))
			return get({ email : null, msg : "Invalid email" });

		// validate args.pass
		if (args.pass.length < 6 || args.pass.length > 64)
			return get({ email : args.email, msg : "Password length must be between 6 and 64" });
		// pre-check if a user already exists
		if (data.users.findOne({ email : args.email }) != null)
			return get({ email : args.email, msg : 'Email ${args.email} already registred' });

		// attempt to create the user
		var p = Password.create(args.pass);
		var u = {
			_id : new ObjectID(),
			name : 'User ${args.email}',
			email : args.email,
			password : p,
			avatar : null,
			points : 0,
		};
		data.users.insert(u);  // FIXME handle possible errors

                return new route.Login(_ctx).post(args);  // TODO fix
	}
}

