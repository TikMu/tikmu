package dispatch;
import croxit.*;

class Question
{
	public static function run(q:db.Question)
	{
		Output.print( new view.QuestionList().setData({ question: q }).execute() );
	}
}

