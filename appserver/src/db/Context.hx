package db;
import org.mongodb.*;

class Context
{
	public var users(default,null):Manager<User>;
	public var sessions(default,null):SessionCache;

	public function new(db:Database)
	{
		this.sessions = new SessionCache(new Manager<Session>(db.session));
		this.users = new Manager<User>(db.user);
	}
}
