package tools;

class History
{
	public static function back()
	{
#if cpp
		return "";
		// if (last == null)
		// 	return "#";
		// else
		// 	return last.substr(1);
#else
		return "javascript: window.history.back(-1);";
#end
	}

	public static function request()
	{
		last = croxit.Web.getURI();
	}

	private static var last:String;
}
