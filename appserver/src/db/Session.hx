package db;
import geo.*;
import geo.units.*;

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

	private static function generateCsrf()
	{
		//FIXME: NOT IMPLEMENTED
		return "??";
	}

	private static function generateId()
	{
		//FIXME: NOT IMPLEMENTED
		return "??";
	}
}

typedef SessionData = {
	_id : String, //nosso
	csrf : String, //token
	loc : Location,
	user : Null<Ref<User>>, // readonly
	creation : Date,
	expires : Date, // nullable: tokens que nao expiram
	closedAt : Null<Ref<Date>>,

	deviceType : DeviceType,
	ip : String,
}

@:enum abstract DeviceType(String)
{
	var Desktop = "desktop";
	var Mobile = "mobile";
}
