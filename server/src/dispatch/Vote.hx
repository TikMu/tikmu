package dispatch;

class Vote
{
	public static function run(answer:db.Answer, value:Int)
	{
		trace(answer,value);
		if (value == 0) return;
		value = value < 0 ? -1 : 1;
		var user = db.Session.currentUser();
		var rate = db.AnswerRate.manager.select($user == user && $answer == answer);
		if (rate == null)
		{
			rate = new db.AnswerRate();
			rate.user = user;
			rate.answer = answer;
			rate.value = value;
			rate.insert();
		} else if (rate.value == value) {
			trace('here1');
			// deletar o que existe ja
			value = -value;
			rate.delete();
		} else {
			trace('here2');
			rate.value = value;
			rate.update();
			if (value < 0) value--;
			else value++;
		}
		sys.db.Manager.cnx.request('UPDATE Answer SET rate = rate ' + (value > 0 ? ' +' + value : ""+ value) + ' WHERE id = ' + answer.id);
		croxit.Web.redirect('/question/' + answer.question.id);
	}
}
