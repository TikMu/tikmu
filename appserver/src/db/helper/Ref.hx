package db.helper;
import org.bsonspec.*;
import org.mongodb.Collection;

typedef K = ObjectID;

typedef Object<K> = {
	_id : K
}

@:forward abstract Ref<V:Object<K>>(K) from K to K
{
	inline public function new(id)
	{
		this = id;
	}

	public function get(c:Collection):V
	{
		return c.findOne({ '_id' : this });
	}

	@:from public static function fromObject<V:Object<K>>(o:V)
	{
		return new Ref(o._id);
	}

	@:extern inline public function asId():ObjectID
		return this;
}

