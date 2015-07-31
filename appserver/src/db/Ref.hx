package db;

import org.bsonspec.*;
import org.mongodb.Collection;

typedef K = ObjectID;

typedef Object<K> = {
	_id : K
}

@:forward abstract Ref<V:Object<K>>(K) from K to K {
	public inline function new(id)
		this = id;

	@:from public static function fromObject<V:Object<K>>(o:V):Ref<V>
		return new Ref(o._id);

	public function get(c:Collection):V
		return c.findOne({ '_id' : this });

	public inline function asId():ObjectID
		return this;
}

