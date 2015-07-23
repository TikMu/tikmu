package db;

import db.Question;
import db.UserActions;
import db.helper.Ref;

class UserActionsTools {
	public static function questionSummary(actions:Null<UserActions>, question:Ref<Question>):Null<QuestionActions>
	{
		if (actions == null)
			return null;
		return Lambda.find(actions.onQuestion, function (x) return x.question.equals(question));
	}

	public static function answerSummary(actions:Null<UserActions>, answer:Ref<Answer>):Null<AnswerActions>
	{
		if (actions == null)
			return null;
		return Lambda.find(actions.onAnswer, function (x) return x.answer.equals(answer));
	}
}

