import croxit.Web;
import org.mongodb.*;

class Main {
	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
		Sys.stderr().writeString(s);
	}

	static function main()
	{
		haxe.Log.trace = customTrace;
		if (Web.isModNeko || Web.isTora)
			Web.cacheModule(main);

		trace('Request: ${Web.getMethod()} ${Web.getURI()}');
		trace('SessionCache usage: ${ctx.data.sessions.used} (capacity ${ctx.data.sessions.size})');

		ctx.respond();
	}
}

