import org.bsonspec.ObjectID in ObjectIdImpl;

/*
   A wraper for Mongo's ObjectId with helper methods and implicit cast rules.

   The purpose of this wraper is to make it easier to write routes that deal
   with ObjectIds, like /questions/<id>.
*/
@:forward abstract ObjectId(ObjectIdImpl) from ObjectIdImpl to ObjectIdImpl {
	public inline function new(?id)
	{
		this = id != null ? id : new ObjectIdImpl();
	}

	@:to public inline function toString()
	{
		return this.bytes.toHex();
	}

	@:from public inline static function fromString(s:String)
	{
		return new ObjectId(ObjectIdImpl.fromString(s));
	}

}

