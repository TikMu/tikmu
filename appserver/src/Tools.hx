import croxit.Web;

class Tools
{
	public static function getIp()
	{
		return Web.getClientIP();
	}

	public static function validEmail(email:String):Bool
	{
		// doc: RFC 3696
		return if (email.length > 320) {  // local (64) + @ (1) + domain (255)
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
}

