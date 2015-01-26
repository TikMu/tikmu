package db;
import org.mongodb.*;

class Context
{
	// public var db(default,null):Database;
	public var questions(default,null):Manager<Question>;
	public var sessions(default,null):SessionCache;
	public var users(default,null):Manager<User>;

	@:allow(Main)
	public var session(default, null):Null<Session>;

	public function new(db:Database)
	{
		// this.db = db;
		this.questions = new Manager<Question>(db.question);
		this.sessions = new SessionCache(new Manager<Session>(db.session));
		this.users = new Manager<User>(db.user);
	}
}
