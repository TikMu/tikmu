package db;

class UserTools {
	public static function update(user:User, data:StorageContext):Void
	{
		data.users.update({ _id : user._id }, user);
	}

	public static function getUserActions(user:Ref<User>, data:StorageContext, ?create=false):Null<UserActions>
	{
		var actions = data.userActions.findOne({ _id : user });
		if (!create)
			return actions;

		if (actions == null) {
			actions = {
				_id : user,
				onQuestion : [],
				onAnswer : []
			}
			data.userActions.insert(actions);
		}
		return actions;
	}

	public static function getUserNotifications(user:Ref<User>, data:StorageContext, ?create=false):Null<UserNotifications>
	{
		var notifications = data.userNotifications.findOne({ _id : user });
		if (!create)
			return notifications;

		if (notifications == null) {
			notifications = {
				_id : user,
				unread : [],
				archive : []
			}
			data.userNotifications.insert(notifications);
		}
		return notifications;
	}
}

