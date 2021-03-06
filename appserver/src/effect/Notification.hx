package effect;

import db.*;
import db.UserNotifications;
import effect.Event;
import org.bsonspec.ObjectID;
import org.mongodb.Cursor;
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

	function magic(uids:Iterable<Ref<User>>, msg:NotificationMessage, url:String)
	{
		for (uid in uids) {
			var n = uid.getUserNotifications(data, true);
			var nn = { msg : msg, url : url };
			n.unread.push(nn);
			data.userNotifications.update({ _id : n._id }, {
				"$push" : { unread : nn }
			});
			trace('bell: will notify user ${uid.valueOf()} of ${msg} (url: $url)');
		}
	}

	function getFollowers(qid:Ref<Question>):Iterable<Ref<User>>
	{
		var actions = data.userActions.find({ onQuestion : {"$elemMatch":{ question : qid }} }).toArray();
		return actions.map(function (x) return x._id);
		// TODO return lazy iterable instead of array
	}

	public function dispatch(event:Event, ?pos:haxe.PosInfos)
	{
		trace('bell: ${Type.enumConstructor(event)} from ${pos.className}::${pos.methodName}');
		switch (event) {
		case EvAnsPost(a,q):
			magic(getFollowers(q), NoMsgAnswerPosted, '/question/${q._id.valueOf()}#${a._id.valueOf()}');
		case EvCmtPost(c,a,q):
			magic(getFollowers(q), NoMsgCommentPosted, '/question/${q._id.valueOf()}#${c._id.valueOf()}');
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

