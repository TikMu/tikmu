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

	public function setPass(pass:String)
	{
		var salt = Std.random(0x7FFFFFF);
		this.hashpass = salt + ":" + haxe.crypto.Sha256.encode(salt + pass + "ESSE É UM SALT DIFICIL PRO JONAS");
	}

	public function checkPass(pass:String):Bool
	{
		var split = this.hashpass.split(':');
		return split[1] == haxe.crypto.Sha256.encode(split[0] + pass + "ESSE É UM SALT DIFICIL PRO JONAS");
	}

	public function getAvatar()
	{
		return avatarAddress != null ? avatarAddress : '/res/img/user.png';
	}
}
