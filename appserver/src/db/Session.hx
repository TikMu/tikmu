package db;

import crypto.Random;
import db.helper.*;
import geo.*;
import geo.units.*;

@:forward
abstract Session(SessionData)
{
	inline public function new(loc,user,span,device)
	{
		this = {
			_id : generateId(),
			csrf : generateCsrf(),
			loc : loc,
			user : user,
			creation : Date.now(),
			expires : DateTools.delta(Date.now(), span),
			closedAt : null,

			deviceType : device,
			ip : Tools.getIp()
		};
	}

	inline public function isValid():Bool
	{
		return this.closedAt == null && this.expires.getTime() > Date.now().getTime();
	}
	
	//It needs a valid session to be authenticated anyway, 
	//so calling isValid here to avoid direct calls.
	inline public function isAuthenticated():Bool
	{
		return isValid() && this.user != null;
	}

	inline public function close()
	{
		this.closedAt = Date.now();
	}

	private static function generateCsrf()  // FIXME
	{
		return "??";
	}

	private static function generateId()
	{
		// first...
		//  - m                                    space
		//  - n                                    number of random strings tested
		//  - p(n)                                 probability of at least one colision in n
		//  - m = n*n*p(n)/2                       birthday attack approximation
		//  - log(m) = 1 + 2*log(n) + log(p(n))    in log base 2, or "bits" (log(p) => negative)
		//  - p(n) ~ 0.5  =>  log(m) ~ 2*log(n)    or m ~ n*n
		// now...
		//  - we want the attacker to need to compute an infeasible number of hashes
		//  - we want p(n) < 0.5 for n = our active strings + attacker's test strings 
		// so, assuming
		//  - u users
		//  - f valid sessions per user
		//  - c server available capacity (to the attacker/everything else failed scenario) per second
		//  - t time to live per session in seconds
		// we can say
		//  - n = u*f + c*t
		//  - n <= 2*max(u*f, c*t)
		//  - log(n) ~ 1 + max(log(u*f), log(c*t))
		// currently: all values are log(_)
		// TODO move to separate autoconfig class
		var u = 10;
		var f = 10;
		var c = u + 10;  // u*1000
		var t = Math.ceil(Math.log(3600*24));
		var n = 1 + Math.max(u + f, c + t);
		var m = n*2;
		var M = Math.ceil(m/8);
		// trace('u=2**$u,f=2**$f,c=2**$c,t=2**$t,n=2**$n,m=2**$m,bytes=$M');
		return Random.id(M);
	}
}

typedef SessionData = {
	_id : String, //nosso
	csrf : String, //token
	loc : Location,
	user : Null<Ref<User>>, // readonly
	creation : Date,
	expires : Date, // nullable: tokens que nao expiram
	closedAt : Null<Date>,

	deviceType : DeviceType,
	ip : String,
}

@:enum abstract DeviceType(String)
{
	var Desktop = "desktop";
	var Mobile = "mobile";
}
