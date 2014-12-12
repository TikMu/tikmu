package db;
import db.helper.*;

/**
	indexes: (user, question) e (user, pendingNotifications.length)
**/
typedef WatchLink = {
	user : Ref<User>,
	question : Ref<Question>,
	pastNotifications : Array<Notification>,
	pendingNotifications : Array<Notification>,
}

typedef Notification = {
	question : Ref<Question>,
	read : Bool
}
