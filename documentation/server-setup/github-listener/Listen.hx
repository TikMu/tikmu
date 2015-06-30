import Sys.*;
import neko.Web;
using StringTools;

typedef Path = String;
typedef Url = String;

typedef ShortUser = {
    name : String,  // this actually is the username
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

enum EventType {
    EPing;
    EPush;
    EOther;
}

class Listen {
    static var config = {
        remote : "origin",
        repository : "jonasmalacofilho/tikmu",
        baseDir : "/var/build/tikmu",
        baseBuildDir : "/var/build/tikmu-builds",
        baseOutputDir : "/var/www/tikmu"
    }

    static function getEventType():EventType
    {
        return
            switch (Web.getClientHeader("X-GitHub-Event")) {
            case "ping": EPing;
            case "push": EPush;
            case _: EOther;
            }
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

    static function _main()
    {
        var event = getEventType();
        if (event.match(EPing))
            return Web.setReturnCode(200);
        if (event.match(EOther)) {
            Web.setReturnCode(417);  // expectation failed
            println('Expecting "push" or "ping" events');
        }

        var data = Web.getPostData();
        var push = (haxe.Json.parse(data):PushEvent);

        if (push.repository.full_name != config.repository) {
            Web.setReturnCode(417);  // expectation failed
            println('Expecting repository to be "${config.repository}"');
        }

        var branch = push.ref.replace("refs/heads/", "");
        var head = push.head_commit.id;
        Web.setReturnCode(202);

        setCwd(config.baseDir);
        command("git", ["fetch", config.remote]);

        var buildDir = '${config.baseBuildDir}/$branch';
        Build.build(config.baseDir, head, buildDir);

        var outputDir = '${config.baseOutputDir}/$branch';
        rmrf(outputDir);
        cpr('$buildDir/appserver/www', outputDir);

        var infos = {
            built_at : Date.now(),
            branch : branch,
            commit : {
                id : push.head_commit.id,
                timestamp : push.head_commit.timestamp,
                author : push.head_commit.author.name,
                message : push.head_commit.message,
            }
        }

        sys.io.File.saveContent('$outputDir/infos.json', haxe.Json.stringify(infos));
    }

    static function main()
    {
        try {
            _main();
        } catch (e:Dynamic) {
            println(e);
            var s = haxe.CallStack.exceptionStack();
            println(haxe.CallStack.toString(s));
        }
    }
}

