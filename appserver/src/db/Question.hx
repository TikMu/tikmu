package db;
import db.helper.*;
import org.bsonspec.*;

typedef Question = {
	_id : String,

	user : Ref<User>,
	contents : String,
	tags : Array<String>,
	loc : Location,
	voteSum : Int,
	favorites : Int,
	watchers : Int,

	deleted : Bool,
	created : Date,
	modified : Date,
	solved : Bool,

	//comments : Array<Comment>,
	answers : Array<Answer>,
}

typedef Comment = {
	user : Ref<User>,   
	contents : String,
	created : Date,
	modified : Date,
	deleted : Bool
}

typedef Answer = {
	deleted : Bool,
	user : Ref<User>,
	contents : String,
	loc : Location,
	voteSum : Int,

	created : Date,
	modified : Date,

	comments : Array<Comment>
}
