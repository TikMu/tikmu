package db;

typedef PermaSession = {
	_id : String, // nosso
	creation : Ref<Date>,
	user : Ref<User>,
	expires : Ref<Date>,
	closedAt : Null<Ref<Date>>,
}
