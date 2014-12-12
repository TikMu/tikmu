package db.helper;

abstract Password(String)
{
	// public var kind(get,never):String;
	// public var salt(get,never):String;
	// public var enc(get,never):String;

	public function matches(pass:String):Bool
	{
		return false;
	}
}
