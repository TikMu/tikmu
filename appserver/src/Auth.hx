import Error;
import croxit.Web;
import crypto.Password;
import db.Session;
import mweb.http.Response;
import org.bsonspec.ObjectID;

class Auth {
	static function validEmail(email:String):Bool
	{
		// doc: RFC 3696
		return if (email.length < 3 || email.length > 320) {  // local (64) + @ (1) + domain (255)
			false;
		} else if (email.indexOf("@") != email.lastIndexOf("@")) {
			// don't handle quoted @ for now
			trace('Possible incorrectly invalidated email: "${email}"');
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

		if (!validEmail(email)) {
			trace('Invalid email: "$email"');
			throw EInvalidEmail;
		}

		if (!validName(name)) {
			trace('Invalid name: "$name"');
			throw EInvalidName;
		}

		if (!validPassword(pass)) {
			trace('Invalid password: len=${pass.length}');
			throw EInvalidPass;
		}

		if (ctx.data.users.findOne({ email : email }) != null) {
			trace('User already exists: "$email"');
			throw EUserAlreadyExists;
		}

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
		trace('Created user for "${u.email}" (${u.name})');
	}

	public static function login(ctx:Context, email:String, pass:String)
	{
		email = StringTools.trim(email);

		if (!validEmail(email)) {
			trace('Invalid email: "$email"');
			throw EInvalidEmail;
		}

		if (!validPassword(pass)) {
			trace('Invalid password: len=${pass.length}');
			throw EInvalidPass;
		}

		var user = ctx.data.users.findOne({ email : email });
		if (user == null || !user.password.matches(pass)) {
			trace('Failed login for "$email": bad ${user == null ? "user" : "password" }');
			if (pass.indexOf("'") > 0)
				trace("Possible SQL injection attempt");
			throw EFailedLogin;
		}

		var s = new Session(null, user._id, 1e9, null);  // FIXME loc, device and real span
		ctx.data.sessions.save(s);
		ctx.loop.session = s;
		trace('Logged in as "${user.email}" (${user.name}) with session ${s._id}');
	}

	/**
		Authorize from session cookie, http basic auth or as guest
	**/
	public static function authorize(ctx:Context)  // TODO receive Request
	{
		var cookies = Web.getCookies();
		if (cookies.exists("_session")) {
			var sid = cookies.get("_session");
			if (sid != "")
				ctx.loop.session = ctx.data.sessions.get(sid);
		}

		var basic = Web.getAuthorization();
		if (basic != null)
			trace('Received basic http creds for "${basic.user}"');
		if (ctx.loop.session == null && basic != null) {
			trace("Trying HTTP basic auth");
			try login(ctx, basic.user, basic.pass)
			catch (err:AuthenticationError) trace(err);
		}
		
		if (ctx.loop.session != null && !ctx.loop.session.isValid()) {
			trace("Ignoring invalid session");
			ctx.loop.session = null;
		}

		if (ctx.loop.session == null) {
			var s = new Session(null, null, 1e9, null);  // FIXME loc, device and real span
			ctx.data.sessions.save(s);
			ctx.loop.session = s;
		}
	}

	/**
		Set updated session cookie when necessary
	**/
	public static function sendSession(ctx:Context, response:Response<Dynamic>)
	{
		var cookies = Web.getCookies();
		if (cookies.get("_session") != ctx.loop.session._id)
			response.setCookie("_session", ctx.loop.session._id, ["path=/"]);
		else if (!ctx.loop.session.isValid())
			response.setCookie("_session", "", ["path=/"]);
	}
}

