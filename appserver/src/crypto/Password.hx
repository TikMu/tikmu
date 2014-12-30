package crypto;

enum PasswordSecurity {
    SPlain;
    SSha256(it:Int, salt:String);
}

abstract Password(String) {

    public var security(get, never):PasswordSecurity;
    public var hash(get, never):String;

    static function makePreffix(security)
    {
        return switch (security) {
        case SPlain:
            "plain$";
        case SSha256(it, salt):
            "sha256$" + it + "$" + salt + "$";
        }
    }

    static function makeHash(plain, security)
    {
        return switch (security) {
        case SPlain:
            plain;
        case SSha256(it, salt):
            var h = plain;
            for (i in 0...it)
                h = haxe.crypto.Sha256.encode(h);
            h;
        }
    }

    function get_security()
    {
        return switch (this.split("$")) {
        case ["plain", _]: SPlain;
        case ["sha256", it, salt, _]: SSha256(Std.parseInt(it), salt);
        case all: throw 'Assert: $all';
        }
    }

    function get_hash()
    {
        return this.substr(this.lastIndexOf("$") + 1);
    }

    public function new(plain:String, ?security:PasswordSecurity)
    {
        // current minimum accepted security
        if (security == null)
            security = SSha256(42, Random.salt(3));

        this = makePreffix(security) + makeHash(plain, security);
    }

    public function matches(plain:String):Bool
    {
        var h = makeHash(plain, security);
        return h == hash;  // FIXME constant time comparison
    }

}

