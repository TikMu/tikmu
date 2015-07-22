package db;

import db.Question;
using db.QuestionTools;

class AnswerTools {
	public static function update(answer:Answer, question:Question, data:StorageContext)
	{
#if debug
		if (!Lambda.has(question.answers, answer))
			throw "Assert failed: answer object in question.answers";
#end
		question.update(data);
	}
}

