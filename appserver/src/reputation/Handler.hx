package reputation;

import db.Question;
import db.User;
import reputation.Event;
using db.QuestionTools;
using db.UserTools;

class Handler {
	var ctx:Context;
	var data(get,never):StorageContext;
	var loop(get,never):IterationContext;

	inline function get_data() return ctx.data;
	inline function get_loop() return ctx.loop;

	static function derive(event:Event, newTarget:EventTarget)
	{
		return { value : event.value, target : newTarget };
	}

	function scoreQuestion(q:Question, v:Float)
	{
		q.voteSum += Math.round(v);  // TODO voteSum:Float
		q.update(data);
		trace('rep: updated question ${q._id.valueOf()} score: ${q.voteSum}');
	}

	function scoreAnswer(a:Answer, q:Question, v:Int)
	{
		a.voteSum += v;
		q.updateAnswer(a, data);
		trace('rep: updated answer ${a._id.valueOf()} score: ${a.voteSum}');
	}

	function scoreUser(u:User, v:Int)
	{
		u.points += v;
		u.update(data);
		trace('rep: updated user ${u.email} score: ${u.points}');
	}

	function handleQuestion(q:Question, e:Event)
	{
		switch (e.value) {
		case RPostQuestion:  // could be NOOP, but assert
			if (q.voteSum != 0)
				throw 'Question score should start at 0 (${q._id.valueOf()})';
		case RFavoriteQuestion:
			scoreQuestion(q, 1);
		case RUnfavoriteQuestion:
			scoreQuestion(q, -1);
		case RFollowQuestion, RUnfollowQuestion:
			// NOOP

		case RPostAnswer, RUpvoteAnswer:
			scoreQuestion(q, 1);
		case RDownvoteAnswer:
			//NOOP

		case RPostComment:
			scoreQuestion(q, .25);
		}
		handle(derive(e, ROwner(q.user.get(data.users.col))));
	}

	function handleAnswer(a:Answer, q:Question, e:Event)
	{
		switch (e.value) {
		case RPostQuestion, RFavoriteQuestion, RUnfavoriteQuestion, RFollowQuestion, RUnfollowQuestion:  // ERROR
			throw "Can't handle event for answer: " + e.value;

		case RPostAnswer:  // could be NOOP, but assert
			if (a.voteSum != 0)
				throw 'Answer score should start at 0 (${a._id.valueOf()})';

		case RUpvoteAnswer:
			scoreAnswer(a, q, 1);
		case RDownvoteAnswer:
			scoreAnswer(a, q, -1);
		case RPostComment:  // NOOP
		}
		handle(derive(e, ROwner(a.user.get(data.users.col))));
		handle(derive(e, RQuestion(q)));
	}

	function handleComment(c:Comment, a:Answer, q:Question, e:Event)
	{
		if (!e.value.match(RPostComment))  // TODO make it a switch, safer that way
			throw "Can't handle event for comment: " + e.value;
		handle(derive(e, RAnswer(a, q)));
	}

	function handleOwner(u:User, e:Event)
	{
		switch (e.value) {
		case RPostQuestion, RFavoriteQuestion:
			scoreUser(u, 1);
		case RUnfavoriteQuestion:
			scoreUser(u, -1);
		case RPostAnswer, RPostComment:
			scoreUser(u, 1);
		case RUpvoteAnswer:
			scoreUser(u, 2);
		case RDownvoteAnswer:
			scoreUser(u, -2);
		case RFollowQuestion, RUnfollowQuestion:  // NOOP
		}
	}

	function handleUser(u:User, e:Event)
	{
		switch (e.value) {
		case RPostQuestion, RPostComment:
			scoreUser(u, 1);
		case RPostAnswer:
			scoreUser(u, 2);
		case RUpvoteAnswer:
			scoreUser(u, 10);
		case RDownvoteAnswer:
			scoreUser(u, -10);
		case RFavoriteQuestion, RUnfavoriteQuestion, RFollowQuestion, RUnfollowQuestion:  // NOOP
		}
	}

	function handle(event:Event)
	{
		trace('rep: handling ${event.value} for ${Type.enumConstructor(event.target)}');
		switch (event.target) {
		case RQuestion(q): handleQuestion(q, event);
		case RAnswer(a, q): handleAnswer(a, q, event);
		case RComment(c, a, q): handleComment(c, a, q, event);
		case ROwner(u): handleOwner(u, event);
		}
	}

	public function update(event:Event)
	{
		handle(event);
		trace('rep: handling ${event.value} for the author user');
		if (loop.session.isAuthenticated())
			handleUser(loop.session.user.get(data.users.col), event);
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

