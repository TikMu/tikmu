package db;
import croxit.Web;
import sys.db.Types;
import sys.db.Object;

@:id(id)
class Session extends Object
{
	public var id:SString<255>;
	public var validUntil:SDate;
	@:relation(user_id) public var user:User;

	private static var hasSet = false;

	public function set()
	{
		if (hasSet) throw "assert";
		Web.setCookie("NSESS", this.id);
	}

	public static function currentUser():User
	{
		var ret = get();
		return ret == null ? null : ret.user;
	}

	public static function get():Session
	{
		var s = Web.getCookies().get("NSESS");
		if (s != null)
		{
			var s = Session.manager.get(s);
			if (s == null)
				return null;
			s.validUntil = DateTools.delta(Date.now(), DateTools.hours(2));
			s.update();
			return s;
		}
		return null;
	}

	public function new()
	{
		super();
		this.id = [ for (i in 0...5) Std.random(1 << 12) ].join("-");
		this.validUntil = DateTools.delta(Date.now(), DateTools.hours(2));
	}
}
