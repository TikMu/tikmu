package crypto;

enum PasswordSecurity {
	SPlain;
	SSha256(it:Int, salt:String);
}

abstract Password(String) from String to String {
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
			var h = plain + salt + plain;
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
		return h == hash;  // TODO use constant time comparison
	}

	public static function create(plain:String, ?security:PasswordSecurity):Password
	{
		// current minimum accepted security:
		//  - Sha256 + iterations + salt
		// iterations:
		//  - bitcoin: 58 bits/s at 850k USD/day (april/2015)
		//  - hypothesis: attacker has access to, at most, the equivalent to 1/1000 of the bitcoin network (-10 bits)
		//  - hypothesis: attacker will spend no more than 1 day per password (+16 bits)
		//  - hypothesis: user passwords have very low entropy (protect at least those with 30+ bits)
		//  - we would need 2**34 iterations, which is infeasible at the moment
		//  - TODO use harder key strengthening function
		//  - TODO use better/faster hash implementations (~500 hashes/s on a 3.6 GHz i7 is too little)
		// salt:
		//  - 2**40 (~1T) variations for each password
		if (security == null)
			security = SSha256(42, Random.salt(5));

		var pwd = makePreffix(security) + makeHash(plain, security);
		return pwd;
	}
}

