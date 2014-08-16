package db;
import sys.db.Types;
import sys.db.Object;

class User extends Object
{
	public var id:SId;
	public var name:SText;
	public var email:SString<255>;
	public var hashpass:SText;
	public var avatarAddress:Null<SString<255>>;
	public var rate:SInt;

	public function getAvatar()
	{
		return avatarAddress;
	}
}
