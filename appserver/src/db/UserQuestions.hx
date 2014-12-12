package db;
import db.helper.*;
import org.bsonspec.*;

typedef UserQuestions = {
	_id : Ref<User>,
	data: Array<QuestionData>
}

typedef QuestionData = {
	question : Ref<Question>,
	votes : Array<{ answer:Null<Int>, up:Bool }>,
	favorite : Bool,
}
