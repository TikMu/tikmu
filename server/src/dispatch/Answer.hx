package dispatch;
import croxit.*;

class Answer
{
	public static function run(args:{ question:db.Question, response:String })
	{
		var newans = new db.Answer();
		newans.text = args.response;
		newans.rate = 0;
		newans.date = Date.now();
		newans.user = db.Session.get().user;
		newans.question = args.question;
		newans.insert();
		Web.redirect('/question?q=${args.question.id}');
	}
}
