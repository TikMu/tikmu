package db;

import db.Question;

class QuestionTools {
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

