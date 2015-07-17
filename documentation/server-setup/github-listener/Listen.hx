import Sys.*;
import haxe.crypto.Hmac;
import haxe.io.Bytes;
import neko.Web;
using StringTools;

typedef Path = String;
typedef Url = String;

typedef ShortUser = {
	name : String,	// this actually is the username
	email : String
}

typedef User = {
	name : String,
	email : String,
	username : String
}

typedef Commit = {
	id : String,
	distinct : Bool,
	message : String,
	timestamp : String,
	url : Url,
	author : User,
	committer : User,
	added : Array<Path>,
	removed : Array<Path>,
	modified : Array<Path>
}

typedef Sender = Dynamic;

typedef Repository = {
	id : Int,
	name : String,
	full_name : String,
	owner : ShortUser,
	html_url : Url,
	description : String,
	fork : Bool,
	url : Url,
	created_at : Dynamic,
	update_at : Dynamic,
	pushed_at : Dynamic,
	default_branch : String,
	master_branch : String
		// more properties
		// more urls
}

typedef PushEvent = {
	ref : String,
	before : String,
	after : String,
	created : Bool,
	deleted : Bool,
	forced : Bool,
	base_ref : Dynamic,
	compare : Url,
	commits : Array<Commit>,
	head_commit : Commit,
	repository : Repository,
	pusher : ShortUser,
	sender : Sender
}

class Listen {
	static var config = {
		secret : "not much of a secret, but will have to make due for now",
		remote : "origin",
		repository : "jonasmalacofilho/tikmu",
		baseDir : "/var/build/tikmu",
		baseBuildDir : "/var/build/tikmu-builds",
		baseOutputDir : "/var/www/tikmu",
		haxeArgs : ["-D", "tikmu_require_login", "-D", "tikmu_cache_module"]
	}

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
		var s = '[${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:	$msg\n';
		Sys.stderr().writeString(s);
	}

	static function verifiedSig(data:String, sig:String)
	{
		var sig = sig.toLowerCase().split("=");
		if (sig[0] != "sha1")
			throw 'Unsupported hash algorithm in signature: ${sig[0]}';
		var secret = Bytes.ofString(config.secret);
		var data = Bytes.ofString(data);
		var hmac = new Hmac(SHA1).make(secret, data);
		return hmac.toHex() == sig[1];
	}

	static function rmrf(path:String)
	{
		// this is fucking dangerous, considering path errors and escaping
		// issues...
		//
		// don't use this script with this unless you're brave and have nothing
		// to loose!  you have been warned.
		if (command("rm", ["-rf", path]) != 0)
			throw 'Failed rm -rf command (path: $path)';
	}

	static function cpr(origin:String, destination:String)
	{
		var args = ["-r", origin, destination];
		if (command("cp", args) != 0)
			throw 'Failed copy command (origin: $origin, destination: $destination)';
	}

	static function respond()
	{
		var data = Web.getPostData();
		var sig = Web.getClientHeader("X-Hub-Signature");
		if (!verifiedSig(data, sig)) {
			Web.setReturnCode(403);  // forbidden
			return;
		}

		var delivery = Web.getClientHeader("X-GitHub-Delivery");
		trace('Delivery: $delivery');

		var event = Web.getClientHeader("X-GitHub-Event").toLowerCase();
		trace('Event: $event');
		if (event == "ping") {
			Web.setReturnCode(200);
			return;
		}
		if (event != "push") {
			Web.setReturnCode(417);  // expectation failed
			trace('ERROR: Expecting "push" or "ping" events');
			return;
		}

		var push = (haxe.Json.parse(data):PushEvent);

		if (push.repository.full_name != config.repository) {
			Web.setReturnCode(417);  // expectation failed
			trace('ERROR: Expecting repository to be "${config.repository}"');
			return;
		}

		var ref = push.ref.replace("refs/", "");
		var buildDir = '${config.baseBuildDir}/$ref';
		var outputDir = '${config.baseOutputDir}/$ref';

		if (push.deleted) {
			Web.setReturnCode(202);  // accepted
			trace('Accepted remove request for ref "$ref"');
			rmrf(outputDir);
			return;
		}

		var head = push.head_commit.id;
		trace('Accepted build request for ref "$ref" (head is "${head.substr(0,7)}")');

		trace('Fetching from ${config.remote}');
		setCwd(config.baseDir);
		command("git", ["fetch", config.remote]);

		trace('Calling a build to "$buildDir" with ${config.haxeArgs}');
		Build.begin(config.baseDir, head, buildDir, config.haxeArgs);

		trace('Installing to "$outputDir"');
		rmrf(outputDir);
		cpr('$buildDir/appserver/www', outputDir);

		trace("Adding infos.json");
		var infos = {
			built_at : Date.now(),
			ref : ref,
			commit : {
				id : push.head_commit.id,
				timestamp : push.head_commit.timestamp,
				author : push.head_commit.author.name,
				message : push.head_commit.message,
			}
		}
		sys.io.File.saveContent('$outputDir/infos.json', haxe.Json.stringify(infos));

		Web.setReturnCode(200);  // OK
		println("Build successfull");
	}

	static function main()
	{
		haxe.Log.trace = customTrace;
		Web.cacheModule(main);

		try {
			respond();
		} catch (e:Dynamic) {
			Web.setReturnCode(500);  // Internal Server Error
			println('Build aborted with error: $e');
			var s = haxe.CallStack.exceptionStack();
			trace("Call stack: " + haxe.CallStack.toString(s));
		}
	}
}

