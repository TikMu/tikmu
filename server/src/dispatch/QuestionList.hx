package dispatch;
import db.*;
import croxit.*;
using Lambda;

class QuestionList
{
	public static function run()
	{
		Output.print( new view.QuestionList().setData({ question: getList(1)[0] }).execute() );
	}

	private static function getList(latest:Int):Array<Question>
	{
		return Question.manager.search(1 == 1, { limit: latest, orderBy:[-id] }).array();
	}
}

