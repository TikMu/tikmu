package dispatch;
import croxit.*;

class QuestionList
{
	public static function run()
	{
		Output.print( new view.QuestionList().setData({ question: null }).execute() );
	}
}
