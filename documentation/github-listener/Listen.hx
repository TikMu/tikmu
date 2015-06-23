import neko.Web;
using StringTools;

typedef Path = String;
typedef Url = String;

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

typedef Repository = Dynamic;
typedef Pusher = Dynamic;
typedef Sender = Dynamic;

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
    pusher : Pusher,
    sender : Sender
}

enum EventType {
    EPing;
    EPush;
    EOther;
}

class Listen {
    static function getEventType():EventType
    {
        return
            switch (Web.getClientHeader("X-GitHub-Event")) {
            case "ping": EPing;
            case "push": EPush;
            case _: EOther;
            }
    }

    static function _main()
    {
        var event = getEventType();
        switch (event) {
        case EPing:
            return Web.setReturnCode(200);
        case EOther:
            return Web.setReturnCode(417);  // expectation failed of "push" or "ping"
        case _:
            // continue
        }

        var data = Web.getPostData();
        var push = (haxe.Json.parse(data):PushEvent);
        var branch = push.ref.replace("refs/heads/", "");
        Web.setReturnCode(202);  // accepted

        // ... build
    }

    static function main()
    {
        try {
            _main();
        } catch (e:Dynamic) {
            Web.setReturnCode(500);  // internal unexpected error
            Sys.println(e);
            var s = haxe.CallStack.exceptionStack();
            Sys.println(haxe.CallStack.toString(s.slice(0,1)));
        }
    }
}

