package db;
import sys.db.Types;
import sys.db.Object;

class Answer extends Object
{
	public var id:SId;
	public var text:SText;
	public var rate:SInt;
	public var date:SDate;
	@:relation(user_id) public var user:User;
}


