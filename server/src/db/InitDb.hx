package db;
import sys.db.Sqlite;
import sys.db.TableCreate;
import sys.FileSystem.*;
import croxit.*;

class InitDb
{
	public static function init()
	{
		var file = Web.getCwd() + '/../.private/db.db';
		sys.db.Manager.initialize();
		var ex = exists(file);
		var cnx = sys.db.Manager.cnx = Sqlite.open(file);
		if (!ex)
		{
			TableCreate.create(AnswerRate.manager);
			cnx.request('CREATE UNIQUE INDEX answerrate_user_answer ON AnswerRate (answer_id,user_id)');
			TableCreate.create(Session.manager);
			TableCreate.create(Answer.manager);
			TableCreate.create(Comment.manager);
			TableCreate.create(Location.manager);
			TableCreate.create(Question.manager);
			TableCreate.create(User.manager);
		}
	}
}
