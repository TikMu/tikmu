package dispatch;
import db.*;
import croxit.*;
using Lambda;

class QuestionList
{
	public static function run(cur:Int=0)
	{
		var list = getList(cur);
		Output.print( new view.QuestionList().setData({ question: list[0], nextUrl:'/${cur+1}', lastUrl:cur > 0 ?'/${cur-1}' : '#' }).execute() );
	}

	private static function getList(latest:Int):Array<Question>
	{
		return Question.manager.search(1 == 1, { limit:[latest,1], orderBy:[-id] }).array();
	}
}

