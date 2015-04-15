import croxit.Web;
import org.mongodb.*;

class Main {
	
	static function main()
	{
		haxe.Log.trace = function (msg, ?p) {
			var s = '[${Date.now()}][${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:  $msg\n';
			Sys.stderr().writeString(s);
		}

		var mongo = new Mongo();
		var ctx = new Context(mongo.tikmu);

		/* TODO rinse and repeat */ {
			ctx.respond();
		}
	}

}

