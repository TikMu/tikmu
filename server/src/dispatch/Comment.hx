package dispatch;
import croxit.*;

class Comment
{
	public static function run(answer:db.Answer,args:{ text:String })
	{
		var comment = new db.Comment();
		comment.answer = answer;
		comment.text = args.text;
		comment.date = Date.now();
		comment.insert();
		Web.redirect('/question/${answer.question.id}');
	}
}
