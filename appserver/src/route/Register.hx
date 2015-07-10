package route;

import crypto.Password;
import mweb.http.*;
import mweb.http.Status;
import mweb.tools.*;
import org.bsonspec.ObjectID;

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
		return respond(cast {}, OK, null);
	}

	@openRoute @login
	public function post(args:{ email:String, name:String, pass:String }):Response<Dynamic>
	{
		args.email = StringTools.trim(args.email);
		args.name = StringTools.trim(args.name);

		if (args.email.length == 0)
			return respond(args, BadRequest, "Missing email");
		if (!Auth.validEmail(args.email))
			return respond(args, BadRequest, "Invalid email");

		if (args.pass.length < 6 || args.pass.length > 64)
			return respond(args, BadRequest, "Password must have between 6 and 64 characters");

		if (args.name.length == 0 || args.name.length > 32)
			return respond(args, BadRequest, "Please use a name between 1 and 32 characters long");

		if (data.users.findOne({ email : args.email }) != null)
			return respond(args, Conflict, "Email already registred");

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

	public function new(ctx)
	{
		super(ctx);
		view = new RegisterView(ctx);
	}
}

