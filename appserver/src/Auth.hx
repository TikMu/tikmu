import Error;
import crypto.Password;
import db.Session;
import org.bsonspec.ObjectID;

class Auth {
	static function validEmail(email:String):Bool
	{
		// doc: RFC 3696
		return if (email.length < 3 || email.length > 320) {  // local (64) + @ (1) + domain (255)
			false;
		} else if (email.indexOf("@") != email.lastIndexOf("@")) {
			// don't handle quoted @ for now
			trace('Possible incorrectly invalidated email: ${email}');
			false;
		} else {
			var at = email.indexOf("@");
			if (at > 64)  // local.length should be <= 64
				false;
			else if (email.length - at - 1 > 255)  // domain.length should be <= 255
				false;
			else
				true;
		}
	}

	static function validPassword(password:String):Bool
	{
		return password.length >= 6 && password.length <= 64;  // TODO remove this magic number
	}

	static function validName(name:String):Bool
	{
		return name.length > 0 && name.length <= 32;
	}

	public static function register(ctx:Context, email:String, name:String, pass:String)
	{
		email = StringTools.trim(email);
		name = StringTools.trim(name);

		if (!validEmail(email))
			throw EInvalidEmail;

		if (!validName(name))
			throw EInvalidName;

		if (!validPassword(pass))
			throw EInvalidPass;

		if (ctx.data.users.findOne({ email : email }) != null)
			throw EUserAlreadyExists;

		var p = Password.create(pass);
		var u = {
			_id : new ObjectID(),
			name : name,
			email : email,
			password : p,
			avatar : null,
			points : 0,
		};
		ctx.data.users.insert(u);
		trace('Created user for ${u.email} (${u.name})');
	}

	public static function login(ctx:Context, email:String, pass:String)
	{
		email = StringTools.trim(email);

		if (!validEmail(email))
			throw EInvalidEmail;

		if (!validPassword(pass))
			throw EInvalidPass;

		var user = ctx.data.users.findOne({ email : email });
		if (user == null || !user.password.matches(pass))
			throw EFailedLogin;

		var s = new Session(null, user._id, 1e9, null);  // FIXME loc, device and real span
		ctx.data.sessions.save(s);
		ctx.loop.session = s;
		trace('Logged in as ${user.email} (${user.name}) with session ${s._id}');
	}
}

