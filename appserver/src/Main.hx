import croxit.Web;
import org.mongodb.*;

class Main {
	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		var s = '[${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
		Sys.stderr().writeString(s);
	}

	static function main()
	{
		haxe.Log.trace = customTrace;
#if tikmu_cache_module
		if (Web.isModNeko || Web.isTora)
			Web.cacheModule(main);
#end

		ctx.respond();
	}
}

