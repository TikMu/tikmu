package dispatch;
import croxit.*;
using Lambda;

class Question
{
	public static function run(q:db.Question)
	{
		var ans = [ for (ans in db.Answer.manager.search($question == q)) {
			comments:db.Comment.manager.search( $answer == ans ).array(),
			rateValue: db.AnswerRate.getRateValue(ans),
			rate: ans.rate,
			user: ans.user,
			text: ans.text,
			id: ans.id
		} ];
		Output.print( new view.Question().setData({ question: q, answers:ans }).execute() );
	}
}

