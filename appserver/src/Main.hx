import croxit.Web;
import org.mongodb.*;

class Main {
	static var stderr = Sys.stderr();

	static var mongo = new Mongo();
	static var ctx = new Context(mongo.tikmu);

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
		msg = '$msg  @${p.className}::${p.methodName}(${p.fileName}:${p.lineNumber})';
		if (ctx.loop != null) {
			msg = '[${ctx.loop.hash}] $msg';
			if (msg.indexOf("\n") >= 0)
				msg = StringTools.replace(msg, "\n", "\n" + StringTools.rpad("", " ", ctx.loop.hash.length + 3));
		}
		Sys.stderr().writeString(msg + "\n");
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
			trace('Exception: $e' + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			Web.setReturnCode(500);  // internal server error
		}

		Sys.stdout().close();
		try {
			var ti = haxe.Timer.stamp();
			ctx.executeDeferred();
			var tf = haxe.Timer.stamp();
			trace('spent additional ${Std.int((tf-ti)*1000)} ms executing deferred tasks');
		} catch (e:Dynamic) {
			trace('Exception during deferred tash execution: $e' + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		}
	}
}

