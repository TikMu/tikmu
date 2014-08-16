package db;
import sys.db.Types;
import sys.db.Object;

class AnswerRate extends Object
{
	public var id:SId;
	public var value:SInt;
	@:relation(user_id) public var user:User;
	@:relation(answer_id) public var answer:Answer;

	public static function getRateValue(answer:Answer):Int
	{
		var sess = Session.get();
		if (sess == null || sess.user == null)
			return 0;
		var ret = AnswerRate.manager.select($user == sess.user && $answer == answer);
		if (ret == null)
			return 0;
		return ret.value;
	}
}
