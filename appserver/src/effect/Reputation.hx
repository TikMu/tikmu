package effect;

import db.Question;
import db.User;
using db.QuestionTools;
using db.UserTools;

class Reputation {
	var ctx:Context;
	var data(get,never):StorageContext;
		inline function get_data() return ctx.data;
	var loop(get,never):IterationContext;
		inline function get_loop() return ctx.loop;
	var users:Array<User>;

	function getUser(uid:db.helper.Ref<User>)
	{
		var u = Lambda.find(users, function (x) return x._id.equals(uid));
		if (u == null) {
			u = uid.get(data.users.col);
			if (u == null)
				throw 'Assert fail: missing user ${uid.valueOf()}';
			users.push(u);
		}
		return u;
	}

	function evName(ev:Event)
	{
		return Type.enumConstructor(ev);
	}

	function questionHandler(ev:Event)
	{
		function addVote(qst:Question, amount:Int) {
			qst.voteSum += amount;
			trace('rep: updated question ${qst._id.valueOf()} score to ${qst.voteSum} (added $amount)');
		}

		trace('rep: applying ${evName(ev)} for Question');
		switch (ev) {
		case EvQstFavorite(qst), EvAnsPost(_,qst), EvAnsUpvote(_,qst):
			addVote(qst, 1);
			ownerHandler(ev, getUser(qst.user));
			return qst;
		case EvCmtPost(_,_,qst):
			addVote(qst, 1);
			// don't dispatch an owner update, not immediate parent of comment
			return qst;
		case EvQstUnfavorite(qst):
			addVote(qst, -1);
			ownerHandler(ev, getUser(qst.user));
			return qst;
		case EvQstFollow(qst), EvQstUnfollow(qst), EvAnsDownvote(_,qst):
			ownerHandler(ev, getUser(qst.user));
			return qst;
		case EvQstPost(qst):
			return qst;
		}
	}

	function answerHandler(ev:Event)
	{
		function addVote(ans:Answer, amount:Int) {
			ans.voteSum += amount;
			trace('rep: updated answer ${ans._id.valueOf()} score to ${ans.voteSum} (added $amount)');
		}

		trace('rep: applying ${evName(ev)} for Answer');
		switch (ev) {
		case EvAnsUpvote(ans,_):
			addVote(ans, 1);
			ownerHandler(ev, getUser(ans.user));
		case EvAnsDownvote(ans,_):
			addVote(ans, -1);
			ownerHandler(ev, getUser(ans.user));
		case EvCmtPost(_,ans,_):
			ownerHandler(ev, getUser(ans.user));
		case _:
			// NOOP
		}
		return questionHandler(ev);
	}

	function commentHandler(ev:Event)
	{
		trace('rep: applying ${evName(ev)} for Comment');
		return switch (ev) {
		case EvCmtPost(_,ans,_): answerHandler(ev);
		case _: throw "Assert fail";
		}
	}

	function ownerHandler(ev:Event, user:User)
	{
		trace('rep: applying ${evName(ev)} for User (owner)');
		var amount = switch (ev) {
		case EvAnsUpvote(_): 2;
		case EvAnsDownvote(_): -2;
		case EvQstFavorite(_), EvAnsPost(_), EvCmtPost(_): 1;
		case EvQstUnfavorite(_): -1;
		case _: 0;  // NOOP
		}
		if (amount != 0) {
			user.points += amount;
			trace('rep: updated user ${user.email} score to ${user.points} (added $amount)');
		}
	}

	function authorHandler(ev:Event, user:User)
	{
		trace('rep: applying ${evName(ev)} for User (action author)');
		var amount = switch (ev) {
		case EvAnsPost(_): 2;
		case EvQstPost(_), EvCmtPost(_): 1;
		case _: 0;  // NOOP
		}
		if (amount != 0) {
			user.points += amount;
			trace('rep: updated user ${user.email} score to ${user.points} (added $amount)');
		}
	}

	public function dispatch(event:Event)
	{
		users = [];  // clear the user cache

		var question = switch (event) {
		case EvQstPost(q), EvQstFavorite(q), EvQstUnfavorite(q), EvQstFollow(q), EvQstUnfollow(q):
			// TODO assert q != null
			questionHandler(event);
		case EvAnsPost(a,q), EvAnsUpvote(a,q), EvAnsDownvote(a,q):
			// TODO assert a != null, q != null, a in q
			answerHandler(event);
		case EvCmtPost(c,a,q):
			// TODO assert c != null, a != null, q != null, c in a, a in q
			commentHandler(event);
		}

		if (loop.session.isAuthenticated())
			authorHandler(event, getUser(loop.session.user));

		if (question == null)
			throw "Assert fail";

		question.update(data);
		for (user in users)
			user.update(data);
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

