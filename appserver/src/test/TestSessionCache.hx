package test;

import crypto.Password;
import org.mongodb.Mongo;
import utest.Assert;

@:access(db.SessionCache)
class TestSessionCache {
	var mongo:Mongo;
	var ctx:StorageContext;

	public function new()
	{
		mongo = new Mongo();
		ctx = new StorageContext(mongo.tikmu_TestSessionCache);
	}

	public function testBasic()
	{
		var u = {
			_id : new org.bsonspec.ObjectID(),
			name : "John",
			email : "john@bot.com",
			password : Password.create("42"),
			avatar : "",
			points : 0
		};
		ctx.users.insert(u);

		var s = new db.Session(null, u._id, 1000, db.Session.DeviceType.Desktop);
		Assert.isNull(s.closedAt);
		Assert.isFalse(ctx.sessions.exists(s._id));

		ctx.sessions.save(s);
		Assert.isTrue(ctx.sessions.cache_has(s._id));
		Assert.isTrue(ctx.sessions.exists(s._id));

		ctx.sessions.terminate(s);
		Assert.notNull(s.closedAt);
		Assert.notNull(ctx.sessions.get(s._id).closedAt);
	}
}

