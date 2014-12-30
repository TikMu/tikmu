package crypto;

enum PasswordSecurity {
    SPlain;
    SSha256(salt:String, it:Int);
}

abstract Password(String) {
    static function makeHash(security, plain)
    {
        return switch (security) {
        case SPlain:
            plain;
        case SSha256(salt, it):
            var ans = plain;
            for (i in 0...it)
                ans = haxe.crypto.Sha256.encode(ans);
            ans;
        }
    }

    function new(x)
    {
        this = x;
    }

    function get_security()
    {
        return switch (this.split("$")) {
        case ["plain", _]: SPlain;
        case ["sha256", salt, it, _]: SSha256(salt, Std.parseInt(it));
        case all: throw 'Assert: $all';
        }
    }

    inline function set_security(security)
    {
        var h = hash;
        var preffix = switch (security) {
        case SPlain:
            "plain$";
        case SSha256(salt, it):
            'sha256$$$salt$$$it$$';
        }
        this = preffix + h;
        return security;
    }

    function get_hash()
    {
        return this.substr(this.lastIndexOf("$") + 1);
    }

    inline function set_hash(plain):String
    {
        var h = makeHash(security, plain);
        this = this.substr(0, this.lastIndexOf("$") + 1) + h;
        return h;
    }

    public var security(get, set):PasswordSecurity;
    public var hash(get, set):String;

    public function matches(plain:String)
    {
        var h = makeHash(security, plain);
        return h == hash;
    }

    public static function make(plain:String, ?security:PasswordSecurity):Password
    {
        if (security == null)
            security = SSha256("FIXME some random salt", 42);
        var a = new Password("$");
        a.security = security;
        a.hash = plain;
        return a;
    }

}

