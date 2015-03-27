package;
import js.Lib;
import js.Functions;
import js.Menu;

class MainJS
{

	public static function main()
	{
		croxit.js.Client.onDeviceReady(function() {
			haxe.Log.trace = function(msg:Dynamic, ?infos:haxe.PosInfos) {
				var pstr = infos == null ? "(null)" : infos.fileName + ":" + infos.lineNumber;
				var str = pstr + ": " +Std.string(msg);
				if( infos != null && infos.customParams != null ) for( v in infos.customParams ) str += "," + Std.string(v);
				untyped __js__('console.log(str)');
				//TODO: assim que o Cauê resolver o remoting
				//croxit.remoting.AsyncConnection.connect().ctx.traceMsg.call([str]);
			}

			untyped js.Lib.window.onerror = function (errorMsg:String, url:String, lineNumber:Int) {
				trace("[ERROR] (" + url + ":" + lineNumber +") " + errorMsg);
			};
		});
	}
}