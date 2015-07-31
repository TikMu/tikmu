package db;

import org.bsonspec.*;

typedef Question = {
	_id : ObjectID,

	user : Ref<User>,
	contents : String,
	tags : Array<String>,
	loc : Location,
	voteSum : Int,  // indirect  // TODO rename and change to Float

	deleted : Bool,
	created : Date,
	modified : Date,  // not changed by including/changing its children
	solved : Bool,

	answers : Array<Answer>,
}

typedef Comment = {
	_id : ObjectID,
	user : Ref<User>,   
	contents : String,
	created : Date,
	modified : Date,
	deleted : Bool
}

typedef Answer = {
	_id : ObjectID,

	deleted : Bool,
	user : Ref<User>,
	contents : String,
	loc : Location,
	voteSum : Int,

	created : Date,
	modified : Date,  // not changed by including/changing its children

	comments : Array<Comment>
}
