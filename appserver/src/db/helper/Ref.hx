package db.helper;
import org.bsonspec.*;
import org.mongodb.Collection;

abstract Ref<T>(ObjectID) from ObjectID to ObjectID
{
	inline public function new(id)
	{
		this = id;
	}

	public function get(c:Collection):T
	{
		return c.findOne({ '_id' : this });
	}
}
