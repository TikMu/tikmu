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

	function handleOwner(u:User, e:Event)
	{
		switch (e.value) {
		case RPostQuestion, RFavoriteQuestion:
			u.points++;
		case RUnfavoriteQuestion:
			u.points--;
		case RFollowQuestion, RUnfollowQuestion:  // NOOP
			return;
		}
		u.update(data);
		trace('updated user reputation: ${u.points}');
	}

	function handleQuestion(q:Question, e:Event)
	{
		switch (e.value) {
		case RPostQuestion:  // could be NOOP, but assert
			if (q.voteSum != 0)
				throw 'Question score should start at 0 (${q._id})';
			return;
		case RFavoriteQuestion:
			q.voteSum++;
		case RUnfavoriteQuestion:
			q.voteSum--;
		case RFollowQuestion, RUnfollowQuestion:  // NOOP
		}
		q.update(data);
		trace('updated question score: ${q.voteSum}');
		handle(derive(e, ROwner(q.user.get(data.users.col))));
	}

	function handleUser(u:User, e:Event)
	{
		switch (e.value) {
		case RPostQuestion:
			u.points++;
		case RFavoriteQuestion, RUnfavoriteQuestion, RFollowQuestion, RUnfollowQuestion:  // NOOP
			return;
		}
		u.update(data);
		trace('updated user reputation: ${u.points}');
	}

	public function handle(event:Event)
	{
		switch (event.target) {
		case RQuestion(q): handleQuestion(q, event);
		case ROwner(u): handleOwner(u, event);
		}
		if (loop.session.isAuthenticated())
			handleUser(loop.session.user.get(data.users.col), event);
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

