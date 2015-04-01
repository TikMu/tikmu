package db;
import org.mongodb.*;

class Context
{
	// public var db(default,null):Database;
	public var questions(default,null):Manager<Question>;
	public var sessions(default,null):SessionCache;
	public var users(default,null):Manager<User>;
	public var userQuestions(default,null):Manager<UserQuestions>;

	@:allow(Main)
	@:allow(routes.login.LoginRoute)
	public var session(default, null):Session;

	public function new(db:Database)
	{
		// this.db = db;
		this.questions = new Manager<Question>(db.question);
		this.sessions = new SessionCache(new Manager<Session>(db.session));
		this.users = new Manager<User>(db.user);
		this.userQuestions = new Manager<UserQuestions>(db.userquestions);
	}
}
