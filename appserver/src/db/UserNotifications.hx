package db;

// (variant=0)(object type)(target type), where:
// reputation = 5, user = 4, comment = 3, answer = 2, question = 1
@:enum abstract NotificationMessage(Int) {
	var NoMsgAnswerPosted = 21;
	var NoMsgCommentPosted = 32;
	var NoMsgAnswerUpvoted = 52;
	var NoMsgAnswerDownvoted = 152;
}

typedef Notification = {
	msg : NotificationMessage,
	url : String
}

typedef UserNotifications = {
	_id : Ref<User>,
	unread : Array<Notification>,
	archive : Array<Notification>
}

