package db;

import db.Question;
import db.helper.Ref;
import org.bsonspec.ObjectID;

typedef QuestionAction = {
	question : Ref<Question>,
	favorite : Bool,
	following : Bool,
}

typedef AnswerAction = {
	answer : Ref<Answer>,
	vote : Int
}

typedef UserActions = {
	_id : Ref<User>,
	onQuestion : Array<QuestionAction>,
	// onAnswer : Array<AnswerAction>
}

