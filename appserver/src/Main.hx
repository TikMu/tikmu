import croxit.Web;
import mweb.Dispatcher;
import mweb.tools.*;
import org.mongodb.Mongo;

class Main
{
	static function main()
	{
		var mongo = new Mongo();
		var ctx = new db.Context(mongo.tikmu);

		var cookies = Web.getCookies();
		if (cookies.exists('TIKMU_SESSID'))
		{
			// handle session
		}

		var d = new Dispatcher(Web);
		d.addMetaHandler(function(metas:Array<String>) {
			//check if user logged, etc
		});

		var route = mweb.Route.anon({
			login: new routes.login.LoginRoute(ctx),
			register: new routes.register.RegisterRoute(ctx),
			list: new routes.list.ListRoute(ctx),
			ask: new routes.ask.AskRoute(ctx),
			question: new routes.question.QuestionRoute(ctx),

			anyDefault: function(d:Dispatcher<Dynamic>) return d.getRoute(routes.list.ListRoute).anyDefault()
		});
		var ret = d.dispatch(route);

		new HttpWriter(new NekoWebWriter()).writeResponse(ret);
	}
}
