package effect;

import db.*;
import db.UserNotifications;
import effect.Event;
using db.UserTools;

/**
  The notification system dispatcher.

  It notifies users when:
   - there are replies to some question being monitored
     (TODO auto follow questions you ask or answer)
   - an answer is upvoted on downvoted
**/
class Notification {
	var ctx:Context;
	var data(get,never):StorageContext;
		inline function get_data() return ctx.data;
	var loop(get,never):IterationContext;
		inline function get_loop() return ctx.loop;

	function magic(uids:Array<Ref<User>>, msg:NotificationMessage, url:String)
	{
		for (uid in uids) {
			var n = uid.getUserNotifications(data, true);
			trace(n);
			n.unread.push({ msg : msg, url : url });
			data.userNotifications.update({ _id : n._id }, n);  // FIXME
			trace('bell: will notify user ${uid.valueOf()} of ${msg} (url: $url)');
		}
	}

	public function dispatch(event:Event, ?pos:haxe.PosInfos)
	{
		// TODO get question followers
		trace('bell: ${Type.enumConstructor(event)} from ${pos.className}::${pos.methodName}');
		switch (event) {
		case EvAnsPost(a,q):
			magic([], NoMsgAnswerPosted, '/question/${q._id.valueOf()}#${a._id.valueOf()}');
		case EvCmtPost(c,a,q):
			magic([], NoMsgCommentPosted, '/question/${q._id.valueOf()}#${c._id.valueOf()}');
		case EvAnsUpvote(a,q):
			magic([a.user], NoMsgAnswerUpvoted, '/question/${q._id.valueOf()}#${a._id.valueOf()}');
		case EvAnsDownvote(a,q):
			magic([a.user], NoMsgAnswerDownvoted, '/question/${q._id.valueOf()}#${a._id.valueOf()}');
		case _:
			trace("bell: noop");
		}
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

