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
		sys.db.Manager.cnx = Sqlite.open(file);
		if (!exists(file))
		{
			TableCreate.create(Answer.manager);
			TableCreate.create(Comment.manager);
			TableCreate.create(Location.manager);
			TableCreate.create(Question.manager);
			TableCreate.create(User.manager);
		}
	}
}
