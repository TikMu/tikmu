package db;
import db.helper.*;
import org.bsonspec.*;

typedef User = {
	_id : ObjectID,
	name : String,
	email : String,
	password : Password,
	avatar : String,
}
