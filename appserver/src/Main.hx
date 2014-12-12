import dispatch.Dispatcher;
import org.mongodb.Mongo;
import croxit.Web;

class Main
{
	static function main()
	{
		var mongo = new Mongo();
		var ctx = new db.Context(mongo.tikmu);
		db.Context.current = ctx;

		Dispatcher.dispatch();
	}
}
