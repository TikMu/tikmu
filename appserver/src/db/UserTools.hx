package db;

class UserTools {
	public static function update(user:User, data:StorageContext)
	{
		data.users.update({ _id : user._id }, user);
	}
}
