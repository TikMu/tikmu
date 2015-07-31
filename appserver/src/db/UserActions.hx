package db;

import db.Question;

typedef QuestionActions = {
	question : Ref<Question>,
	favorite : Bool,
	following : Bool,
}

typedef AnswerActions = {
	answer : Ref<Answer>,
	vote : Int
}

typedef UserActions = {
	_id : Ref<User>,
	onQuestion : Array<QuestionActions>,
	onAnswer : Array<AnswerActions>
}

