import croxit.Web;
import org.mongodb.*;

class Main {
	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
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

		try {
			ctx.respond();
		} catch (e:mweb.Errors.DispatcherError) {
			Web.setReturnCode(404);  // not found
		} catch (e:Dynamic) {
			trace('Exception: $e');
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			Web.setReturnCode(500);  // internal server error
		}
	}
}

