package db;
import sys.db.Types;
import sys.db.Object;

class Question extends Object
{
	public var id:SId;
	public var contents:SText;
	public var isNsfw:SBool;
	public var date:SDate;
	@:relation(user_id) public var user:User;
	@:relation(loc_id) public var location:Location;

	public function getTitle()
	{
		return contents;
	}

	public function canSee():Bool
	{
		if (!isNsfw)
			return true;
		var user = Session.currentUser();
		if (user != null)
			return true;
		return false;
	}
}

