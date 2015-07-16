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

	// copies the question removing deleted answers and comments
	// TODO rename to something clearer
	public static function clean(question:Question)
	{
		var q = Reflect.copy(question);
		var as = [];
		for (a in q.answers) if (!a.deleted) {
			a = Reflect.copy(a);
			var cs = [];
			for (c in a.comments) if (!c.deleted) {
				cs.push(c);
			}
			a.comments = cs;
			as.push(a);
		}
		q.answers = as;
		return q;
	}
}

