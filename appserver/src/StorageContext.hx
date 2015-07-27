import db.*;
import org.mongodb.*;

class StorageContext {
	var db:Database;

	public var questions(default,null):Manager<Question>;
	public var sessions(default,null):SessionCache;
	public var users(default,null):Manager<User>;
	public var userActions(default,null):Manager<UserActions>;
	public var userNotifications(default,null):Manager<UserNotifications>;

	public function new(db)
	{
		this.db = db;

		questions = new Manager<Question>(db.questions);
		sessions = new SessionCache(new Manager<Session>(db.sessions));
		users = new Manager<User>(db.users);
		userActions = new Manager<UserActions>(db.userActions);
		userNotifications = new Manager<UserNotifications>(db.userNotifications);
	}
}

