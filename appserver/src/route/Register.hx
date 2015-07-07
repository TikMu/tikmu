package route;

import crypto.Password;
import mweb.http.*;
import mweb.tools.*;
import org.bsonspec.ObjectID;

@:includeTemplate("register.html")
class RegisterView extends BaseView<{ email:String, name:String, msg:String }> {
}

class Register extends BaseRoute {
	function retry(args, msg)
	{
		return get({ email : args.email, name : args.name, msg : msg});
	}

	@openRoute @login
	public function get(?args:{ email:String, name:String, msg:String }):Response<{ email:String, msg:String }>
	{
		return Response.fromContent(new TemplateLink(args != null ? args : cast {}, new RegisterView(_ctx)));
	}

	@openRoute @login
	public function post(args:{ email:String, name:String, pass:String }):Response<Dynamic>
	{
		if (!Tools.validEmail(args.email))
			return retry(args, "Invalid email");
		if (args.pass.length < 6 || args.pass.length > 64)
			return retry(args, "Password must have between 6 and 64 characters");
		if (args.name.length == 0 || args.name.length > 32)
			return retry(args, "Please use a name between 1 and 32 characters long");

		if (data.users.findOne({ email : args.email }) != null)
			return retry(args, "Email already registred");

		var p = Password.create(args.pass);
		var u = {
			_id : new ObjectID(),
			name : args.name,
			email : args.email,
			password : p,
			avatar : null,
			points : 0,
		};
		data.users.insert(u);
		trace('Created user for ${u.email} (${u.name})');
                return new route.Login(_ctx).post(args);  // TODO fix
	}
}

