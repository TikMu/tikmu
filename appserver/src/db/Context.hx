package db;
import org.mongodb.*;

class Context
{
	public static var current:Context;

	public var user(default,null):Manager<User>;
	private var session(default,null):Manager<Session>;

	public function new(db:Database)
	{
		this.session = new Manager<Session>(db.session);
		this.user = new Manager<User>(db.user);
	}
}
