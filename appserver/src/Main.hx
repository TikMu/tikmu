import croxit.Web;
import org.mongodb.*;

class Main {
	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
		Sys.stderr().writeString(s);
	}

	@:access(db.SessionCache)
	static function main()
	{
		haxe.Log.trace = customTrace;
		neko.Web.cacheModule(main);

		ctx.respond();

		var s = ctx.loop.session;
		trace(ctx.data.sessions.cache_has(s._id));
	}
}

