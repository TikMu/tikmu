package dispatch;
import db.*;
import croxit.*;
using Lambda;

class QuestionList
{
	public static function run(?args:{cur:Int})
	{
		var cur = args == null ? 0 : args.cur;
		var list = getList(cur);
		Output.print( new view.QuestionList().setData({ question: list[0], nextUrl:'?cur=${cur+1}', lastUrl:cur > 0 ?'?cur=${cur-1}' : '#' }).execute() );
	}

	private static function getList(latest:Int):Array<Question>
	{
		return Question.manager.search(1 == 1, { limit:[latest,1], orderBy:[-id] }).array();
	}
}

