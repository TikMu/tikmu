package crypto;

enum PasswordSecurity {
    SPlain;
    SSha256(it:Int, salt:String);
}

abstract Password(String) {

    public var security(get, never):PasswordSecurity;
    public var hash(get, never):String;

    inline function new(pwd)
    {
        this = pwd;
    }

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

    public function matches(plain:String):Bool
    {
        var h = makeHash(plain, security);
        return h == hash;  // FIXME constant time comparison
    }

    public static function create(plain:String, ?security:PasswordSecurity)
    {
        // current minimum accepted security: Sha256 + iterations + salt
        // WARNING: this doesn't protect weak passwords at all!!
        // iterations: FIXME (verify and improve this analysis!!)
        //  - bitcoin: 58+ bits/s (estimate for jan/2015)
        //  - hypothesis: attacker has at most 1M times the bitcoin network => 78 bits
        //  - hypothesis: attacker has 1 year to spend (or more computing power): add 25 bits => 103 bits
        //  - NIST guidelines reduce the security of hashes by half
        //  - so a single sha256 hash has still 25 bits of security in this attack model
        //  - therefore, the iteration count is not important... lets keep 42 for now
        // salt: 2**40 (~1T) variations for each password
        if (security == null)
            security = SSha256(42, Random.salt(5));

        var pwd = makePreffix(security) + makeHash(plain, security);
        return new Password(pwd);
    }

    @:from public static function fromString(pwd:String)
    {
        return new Password(pwd);
    }

}

