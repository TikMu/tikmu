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

typedef Hook = {
	owner : String,
	repository : String,
	secret : String,
	baseBuildDir : String,
	baseOutputDir : String,
	scripts : {
		delete: String,
		prepare: String,
		build: String,
		deploy: String,
	},
	slack : Null<{
		url : String,
		username : Null<String>,
		channel : Null<String>
	}>
}

typedef Config = {
	hooks : Array<Hook>
}

enum ListenMessage {
	MFailedDelete(hook:Hook, ref:String, exitCode:Int, out:String, err:String);
	MDeleted(hook:Hook, ref:String);
	MFailed(hook:Hook, ref:String, head:String, exitCode:Int, out:String, err:String);
	MSuccessful(hook:Hook, ref:String, head:String);
}

class Listen {
	static function customTrace(msg:String, ?p:haxe.PosInfos)
	{
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
		var s = '[${Web.getClientIP()}] ${p.fileName}:${p.lineNumber}:	$msg\n';
		Sys.stderr().writeString(s);
	}

	static function verifiedSig(secret:String, data:String, sig:String)
	{
		var sig = sig.toLowerCase().split("=");
		if (sig[0] != "sha1")
			throw 'Unsupported hash algorithm in signature: ${sig[0]}';
		var secret = Bytes.ofString(secret);
		var data = Bytes.ofString(data);
		var hmac = new Hmac(SHA1).make(secret, data);
		return hmac.toHex() == sig[1];
	}

	static function respond(config:Config)
	{
		var event = Web.getClientHeader("X-GitHub-Event").toLowerCase();
		if (event == "ping") {
			return {
				status : 200,
				msg : null
			};
		} else if (event != "push") {
			trace('ERROR: expected "push" or "ping" but got $event');
			return {
				status : 417,  // expectation failed
				msg : null
			}
		}

		var sig = Web.getClientHeader("X-Hub-Signature");
		var data = Web.getPostData();
		var push:PushEvent = haxe.Json.parse(data);
		var hook = Lambda.find(config.hooks,
			function (h)
				return h.repository == push.repository.name &&
					h.owner == push.repository.owner.name
		);
		if (hook == null) {
			trace('ERROR: no hook set up for ${push.repository.full_name}');
			return {
				status : 404,
				msg : null
			}
		}
		if (!verifiedSig(hook.secret, data, sig)) {
			trace('ERROR: signature did not match');
			return {
				status : 403,  // forbidden
				msg : null
			}
		}

		var ref = push.ref.replace("refs/", "");

		if (push.deleted) {
			trace('accepted delete request for $ref');
			var p = new SimpleProcess(hook.scripts.delete, [hook.baseBuildDir, hook.baseOutputDir, ref]);
			var r = p.simpleRun();
			if (r.exitCode != 0) {
				return {
					status : 500,
					msg : MFailedDelete(hook, ref, r.exitCode, r.stdout.toString(), r.stderr.toString())
				}
			}
			return {
				status : 200,
				msg : MDeleted(hook, ref)
			}
		} else {
			var head = push.head_commit.id;
			trace('accepted build request for $ref at ${head}');
			var out = new haxe.io.BytesBuffer();
			var err = new haxe.io.BytesBuffer();
			for (s in [hook.scripts.prepare, hook.scripts.build, hook.scripts.deploy]) {
				var p = new SimpleProcess(s, [hook.baseBuildDir, hook.baseOutputDir, ref, head]);
				var r = p.simpleRun(out, err);
				if (r.exitCode != 0) {
					return {
						status : 500,
						msg : MFailed(hook, ref, head, r.exitCode, out.getBytes().toString(), err.getBytes().toString())
					}
				}
			}
			return {
				status : 200,
				msg : MSuccessful(hook, ref, head)
			}
		}
	}

	static function reportToSlack(url, payload:Dynamic, username, channel)
	{
		var req = new haxe.Http(url);
		if (username != null)
			payload.username = username;
		if (channel != null)
			payload.channel = channel;
		req.setPostData(haxe.Json.stringify(payload));
		req.request(true);
	}

	static function makeLink(hook:Hook, head:String)
	{
		return '<https://github.com/${hook.owner}/${hook.repository}/commit/$head|${head.substr(0,7)}>';
	}

	static function main()
	{
		haxe.Log.trace = customTrace;
		Web.cacheModule(main);
		try {
			var config = haxe.Json.parse(sys.io.File.getContent("/etc/listen_config.json"));
			var res = respond(config);
			Web.setReturnCode(res.status);
			switch (res.msg) {
			case null:  // NOOP
			case MDeleted(hook, ref):
			case MSuccessful(hook, ref, head):
			case MFailedDelete(hook, ref, exit, out, err):
				err = err.trim();
				var msg = {
					fallback : '[${hook.repository}:$ref] failed to delete',
					title : 'Delete failed',
					text : 'Failed with exit code `$exit`' +
						if (err.length > 0) ':\n```\n$err\n```\n' else '',
					fields : [
						{ title : "Repository", value : '${hook.repository}' },
						{ title : "Ref", value : ref }
					]
				};
				reportToSlack(hook.slack.url, { attachments : [msg] }, hook.slack.username, hook.slack.channel);
			case MFailed(hook, ref, head, exit, out, err):
				err = err.trim();
				var msg = {
					fallback : '[${hook.repository}:$ref] ${makeLink(hook, head)} failed',
					title : 'Build failed',
					text : 'Failed with exit code `$exit`' +
						if (err.length > 0) ':\n```\n$err\n```\n' else '',
					fields : [
						{ title : "Repository", value : '${hook.repository}' },
						{ title : "Ref", value : ref },
						{ title : "Commit", value : head }
					]
				};
				reportToSlack(hook.slack.url, { attachments : [msg] }, hook.slack.username, hook.slack.channel);
			}
		} catch (e:Dynamic) {
			Web.setReturnCode(500);  // internal Server Error
			trace('ERROR: $e');
			var s = haxe.CallStack.exceptionStack();
			trace("Call stack: " + haxe.CallStack.toString(s));
		}
	}
}

