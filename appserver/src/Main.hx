import croxit.Web;
import org.mongodb.*;

class Main {
	static var stderr = Sys.stderr();

	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
		msg = '$msg  @${p.className}::${p.methodName}(${p.fileName}:${p.lineNumber})\n';
		if (ctx.loop != null)
			msg = '[${ctx.loop.hash}] $msg';
		Sys.stderr().writeString(msg);
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

