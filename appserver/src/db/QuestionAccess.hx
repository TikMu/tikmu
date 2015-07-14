package db;

typedef ContextAware = {
	_ctx : Context
}

class QuestionAccess {
	public static function getQuestionMonitoringState(here:ContextAware, questionId:ObjectId)
	{
		var uqq = null;

		var uq = here._ctx.data.userQuestions.findOne({ _id : here._ctx.loop.session.user });  // TODO cache this??
		if (uq != null)
			uqq = Lambda.find(uq.data, function (x) return x.question.equals(questionId));

		var state = if (uqq != null) {
			votes : uqq.votes,
			favorite : uqq.favorite,
			following : uqq.following
		} else {
			votes : [],
			favorite : false,
			following : false
		}

		return state;
	}
}

