package effect;

import db.Question;
using db.QuestionTools;
using db.UserTools;

class Reputation {
	var ctx:Context;
	var data(get,never):StorageContext;
		inline function get_data() return ctx.data;
	var loop(get,never):IterationContext;
		inline function get_loop() return ctx.loop;

	function magic(question:Question, ?answer:Answer, ?comment:Comment,
		amount:{ ?author : Int, ?question : Int, ?questionOwner : Int, ?answer : Int, ?answerOwner : Int})
	{
		var users = new Array<db.User>();
		function getUser(uid:db.helper.Ref<db.User>) {
			var u = Lambda.find(users, function (x) return x._id.equals(uid));
			if (u == null) {
				u = uid.get(data.users.col);
				if (u == null)
					throw 'Missing user ${uid.valueOf()}';
				users.push(u);
			}
			return u;
		}

		var author = null;
		if (amount.author != null && amount.author != 0 && ctx.loop.session.isAuthenticated()) {
			author = getUser(ctx.loop.session.user);
			author.points += amount.author;
			trace('rep: changing user (author) ${author.email} score to ${author.points} (add ${amount.author})');
		}

		if (amount.question != null && amount.question != 0 && question != null) {
			question.voteSum += amount.question;
			trace('rep: changing question ${question._id.valueOf()} score to ${question.voteSum} (add ${amount.question})');
		}

		if (amount.questionOwner != null && amount.questionOwner != 0 && question != null) {
			var owner = getUser(question.user);
			if (owner != author) {
				owner.points += amount.questionOwner;
				trace('rep: changing user (owner) ${owner.email} score to ${owner.points} (add ${amount.questionOwner})');
			}
		}

		if (amount.answer != null && amount.answer != 0 && answer != null) {
			answer.voteSum += amount.answer;
			trace('rep: changing answer ${answer._id.valueOf()} score to ${answer.voteSum} (add ${amount.answer})');
		}

		if (amount.answerOwner != null && amount.answerOwner != 0 && answer != null) {
			var owner = getUser(answer.user);
			if (owner != author) {
				owner.points += amount.answerOwner;
				trace('rep: changing user (owner) ${owner.email} score to ${owner.points} (add ${amount.answerOwner})');
			}
		}

		question.update(data);
		for (user in users)
			user.update(data);
	}

	public function dispatch(event:Event, ?pos:haxe.PosInfos)
	{
		trace('rep: dispatching event ${Type.enumConstructor(event)} from ${pos.fileName}:${pos.lineNumber}');
		switch (event) {
		case EvQstPost(q):
			magic(q, null, null, { author : 1, question : 1 });
		case EvQstFavorite(q):
			magic(q, null, null, { question : 1, questionOwner : 1 });
		case EvQstUnfavorite(q):
			magic(q, null, null, { question : -1, questionOwner : -1 });
		case EvQstFollow(q), EvQstUnfollow(q):
			// NOOP, follow implies favorite
		case EvAnsPost(a,q):
			magic(q, a, null, { author : 2, question : 1, questionOwner : 1 });
		case EvAnsUpvote(a,q):
			magic(q, a, null, { answer : 1, answerOwner : 5, question : 1, questionOwner : 2 });
		case EvAnsDownvote(a,q):
			magic(q, a, null, { answer : -1, answerOwner : -5, question : -1, questionOwner : -2 });
		case EvCmtPost(c,a,q):
			magic(q, a, c, { author : 1, answerOwner : 1, question : 1 });
		}
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

