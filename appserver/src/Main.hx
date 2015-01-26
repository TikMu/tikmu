import mweb.Dispatcher;
import mweb.tools.*;
import org.mongodb.Mongo;
import croxit.Web;

import crypto.Password;

class Main
{
	static function main()
	{
		var mongo = new Mongo();
		var ctx = new db.Context(mongo.tikmu);

		// scratch

		// // password
		// trace(new Password("hello!!!", SPlain));
		// trace(new Password("hello!!!", SPlain).matches("hello!!!"));
		// trace(new Password("hello!!!", SPlain).matches("hello!!"));
		// trace(new Password("hello!!!"));
		// trace(new Password("hello!!!").matches("hello!!!"));
		// trace(new Password("hello!!!").matches("hello!!"));

                // user & session
		// var u = {
		// 	_id : new org.bsonspec.ObjectID(),
		// 	name : "John",
		// 	email : "john@bot.com",
		// 	password : new Password("42"),
		// 	avatar : ""
		// };
		// ctx.users.insert(u);
		// trace(u);
		// var s = new db.Session(null, u._id, 1000, db.Session.DeviceType.Desktop);
		// trace(ctx.sessions.exists(s._id));
		// ctx.sessions.save(s);
		// trace(ctx.sessions.exists(s._id));
		// ctx.sessions.terminate(s);
		// trace(ctx.sessions.get(s._id));

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
			anyDefault: function(d:Dispatcher<Dynamic>) return d.getRoute(routes.list.ListRoute).anyDefault()
		});
		var ret = d.dispatch(route);

		new HttpWriter(new NekoWebWriter()).writeResponse(ret);
	}
}
