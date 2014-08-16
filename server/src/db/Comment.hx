package db;
import sys.db.Types;
import sys.db.Object;

class Comment extends Object
{
	public var id:SId;
	@:relation(answer_id) public var answer:Answer;
	public var text:SText;
	public var date:SDate;
}
