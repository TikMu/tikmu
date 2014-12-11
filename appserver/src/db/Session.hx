package db;

typedef Session = {
	_id : String, //nosso
	csrf : String, //token
	loc : Location,
	user : Null<Ref<User>>, // readonly
	creation : Ref<Date>,
	expires : Ref<Date>, // nullable: tokens que nao expiram
	closedAt : Null<Ref<Date>>,

	deviceType : DeviceType,
	ip : Int,
}

@:enum abstract DeviceType(String)
{
	var Desktop = "desktop";
	var Mobile = "mobile";
}
