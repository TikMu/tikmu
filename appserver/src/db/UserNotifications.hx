package db;

typedef Notification = {
	?msg : String
}

typedef UserNotifications = {
	_id : db.helper.Ref<User>,
	unread : Array<Notification>,
	archive : Array<Notification>
}

