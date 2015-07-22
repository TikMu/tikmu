package db;

import db.Question;

class QuestionTools {
	public static function getQuestionMonitoringState(question:Question, ctx:Context)
	{
		var uqq = null;

		var uq = ctx.data.userActions.findOne({ _id : ctx.loop.session.user });  // TODO cache this??
		if (uq != null)
			uqq = Lambda.find(uq.onQuestion, function (x) return x.question.equals(question._id));

		var state = if (uqq != null) {
			favorite : uqq.favorite,
			following : uqq.following
		} else {
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

	public static function update(question:Question, data:StorageContext)
	{
		data.questions.update({ _id : question._id }, question);
	}

	public static function updateAnswer(question:Question, answer:Answer, data:StorageContext) {
#if debug
		if (!Lambda.has(question.answers, answer))
			throw "Assert failed: answer object in question.answers";
#end
		update(question, data);
	}
}

