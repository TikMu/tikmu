package tikmu;

import db.Question;
import db.User;
import tikmu.Event;
using db.QuestionTools;
using db.UserTools;

class Reputation {
	var ctx:Context;
	var data(get,never):StorageContext;
	var loop(get,never):IterationContext;

	var question:Null<Question>;
	var answer:Null<Answer>;
	var comment:Null<Comment>;
	var users:Array<User>;
	var value:EventValue;

	inline function get_data() return ctx.data;
	inline function get_loop() return ctx.loop;

	static function derive(event:Event, newTarget:EventTarget)
	{
		return { value : event.value, target : newTarget };
	}

	function reset(v:EventValue)
	{
		value = v;
		question = null;
		answer = null;
		comment = null;
		users = [];
	}

	function getUser(uid:db.helper.Ref<User>)
	{
		var u = Lambda.find(users, function (x) return x._id.equals(uid));
		if (u == null) {
			u = uid.get(data.users.col);
			users.push(u);
		}
		return u;
	}

	function scoreQuestion(q:Question, v:Float)
	{
		q.voteSum += Math.round(v);  // TODO voteSum:Float
		trace('rep: updated question ${q._id.valueOf()} score: ${q.voteSum}');
	}

	function scoreAnswer(a:Answer, v:Int)
	{
		a.voteSum += v;
		trace('rep: updated answer ${a._id.valueOf()} score: ${a.voteSum}');
	}

	function scoreUser(u:User, v:Int)
	{
		u.points += v;
		trace('rep: updated user ${u.email} score: ${u.points}');
	}

	function questionHandler()
	{
		if (question == null)
			throw "Assert failed: broken rep handler state";

		trace('rep: handling ${value} for Question');
		switch (value) {
		case RPostQuestion:  // could be NOOP, but assert
			if (question.voteSum != 0)
				throw 'Question score should start at 0 (${question._id.valueOf()})';
			return;  // owner is author

		case RFavoriteQuestion, RPostAnswer, RUpvoteAnswer, RPostComment:
			scoreQuestion(question, 1);
		case RUnfavoriteQuestion:
			scoreQuestion(question, -1);
		case RFollowQuestion, RUnfollowQuestion, RDownvoteAnswer:
			// NOOP
		}

		if (!value.match(RPostComment))  // not immediate parent of comment
			ownerHandler(getUser(question.user));
	}

	function answerHandler()
	{
		if (answer == null)
			throw "Assert failed: broken rep handler state";

		trace('rep: handling ${value} for Answer');
		switch (value) {
		case RPostQuestion, RFavoriteQuestion, RUnfavoriteQuestion, RFollowQuestion, RUnfollowQuestion:  // ERROR
			throw "Can't handle event for answer: " + value;

		case RPostAnswer:  // could be NOOP, but assert
			if (answer.voteSum != 0)
				throw 'Answer score should start at 0 (${answer._id.valueOf()})';

		case RUpvoteAnswer:
			scoreAnswer(answer, 1);
		case RDownvoteAnswer:
			scoreAnswer(answer, -1);
		case RPostComment:  // NOOP
		}

		if (!value.match(RPostAnswer))  // RPostAnswer => owner is author
			ownerHandler(getUser(answer.user));
		questionHandler();
	}

	function commentHandler()
	{
		if (comment == null)
			throw "Assert failed: broken rep handler state";

		trace('rep: handling ${value} for Comment');
		if (!value.match(RPostComment))  // TODO make it a switch, safer that way
			throw "Can't handle event for comment: " + value;

		answerHandler();
	}

	function ownerHandler(user:User)
	{
		if (user == null || !Lambda.has(users, user))
			throw "Assert failed: broken rep handler state";

		trace('rep: handling ${value} for User (owner)');
		switch (value) {
		case RPostAnswer, RPostComment, RFavoriteQuestion:
			scoreUser(user, 1);
		case RUnfavoriteQuestion:
			scoreUser(user, -1);
		case RUpvoteAnswer:
			scoreUser(user, 2);
		case RDownvoteAnswer:
			scoreUser(user, -2);
		case RPostQuestion, RFollowQuestion, RUnfollowQuestion:
			// NOOP
		}
	}

	function authorHandler(user:User)
	{
		if (user == null || !Lambda.has(users, user))
			throw "Assert failed: broken rep handler state";

		trace('rep: handling ${value} for User (action author)');
		switch (value) {
		case RPostQuestion, RPostComment:
			scoreUser(user, 1);
		case RPostAnswer:
			scoreUser(user, 2);
		case RFavoriteQuestion, RUnfavoriteQuestion, RFollowQuestion, RUnfollowQuestion,
			RUpvoteAnswer, RDownvoteAnswer:
			// NOOP
		}
	}

	public function update(event:Event)
	{
		reset(event.value);

		switch (event.target) {
		case RQuestion(q):
			question = q;
			questionHandler();
		case RAnswer(a, q):
			answer = a;
			question = q;
			answerHandler();
		case RComment(c, a, q):
			comment = c;
			answer = a;
			question = q;
			commentHandler();
		}

		if (loop.session.isAuthenticated())
			authorHandler(getUser(loop.session.user));

		question.update(data);
		for (user in users)
			user.update(data);
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

