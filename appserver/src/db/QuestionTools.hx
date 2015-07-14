package db;

class QuestionTools {
	public static function getQuestionMonitoringState(question:Question, ctx:Context)
	{
		var uqq = null;

		var uq = ctx.data.userQuestions.findOne({ _id : ctx.loop.session.user });  // TODO cache this??
		if (uq != null)
			uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));

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

