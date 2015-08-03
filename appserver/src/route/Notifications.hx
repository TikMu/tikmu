package route;

import Error;
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

	public function postRead(args:{ url : String })
	{
		var n = loop.session.user.getUserNotifications(data);
		if (n == null)
			throw ENoMatchingNotification(args.url);

		var matching = Lambda.filter(n.unread, function (x) return x.url == args.url);
		if (matching.length == 0)
			throw ENoMatchingNotification(args.url);

		for (item in matching)
			n.unread.remove(item);
		for (item in matching)
			n.archive.push(item);
		data.userNotifications.update({ _id : n._id }, n);  // TODO handle concurrent updates
		return mweb.http.Response.empty().redirect(args.url);
	}
}

