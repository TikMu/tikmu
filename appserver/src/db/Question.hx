package db;
import db.helper.*;
import org.bsonspec.*;

typedef Question = {
	_id : ObjectID,

	user : Ref<User>,
	contents : String,
	tags : Array<String>,
	loc : Location,
	voteSum : Int,
	favorites : Int,
	watchers : Int,

	created : MongoDate,
	modified : MongoDate,

	comments : Array<Comment>,
	answers : Array<Answer>,
}

typedef Comment = {
	user : Ref<User>,
	contents : String,
	created : MongoDate
}

typedef Answer = {
	deleted : Bool,
	user : Ref<User>,
	contents : String,
	loc : Location,
	voteSum : Int,

	created : MongoDate,
	modified : MongoDate,

	comments : Array<Comment>
}
