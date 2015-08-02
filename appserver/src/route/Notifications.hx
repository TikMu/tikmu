package route;

using db.UserTools;

class Notifications extends BaseRoute {
	public function anyCount()
	{
		var n = loop.session.user.getUserNotifications(data);
		return serialize(n != null ? n.unread.length : 0);
	}

	public function anyList(?args:{ limit:Int })
	{
		var limit = args != null ? args.limit : null;
		var n = loop.session.user.getUserNotifications(data);
		if (n != null && limit != null) {
			n.unread = n.unread.slice(0, limit);
			limit = limit - n.unread.length;
			n.archive = n.archive.slice(0, limit);
		}
		return serialize(n);
	}

	public function postRead(url:String)  // TODO
		return mweb.http.Status.NotFound;
}

