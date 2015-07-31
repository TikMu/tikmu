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

		if (amount.author != null && amount.author != 0 && ctx.loop.session.isAuthenticated()) {
			var author = getUser(ctx.loop.session.user);
			author.points += amount.author;
			trace('rep: changing User (author) ${author.email} score to ${author.points} (add ${amount.author})');
		}

		if (answer != null) {
			if (amount.answer != null && amount.answer != 0) {
				answer.voteSum += amount.answer;
				trace('rep: changing Answer ${answer._id.valueOf()} score to ${answer.voteSum} (add ${amount.answer})');
			}
			if (amount.answerOwner != null && amount.answerOwner != 0) {
				var owner = getUser(answer.user);
				owner.points += amount.answerOwner;
				trace('rep: changing User (answer owner) ${owner.email} score to ${owner.points} (add ${amount.answerOwner})');
			}
		}

		if (question != null) {
			var owner = getUser(question.user);
			if (amount.question != null && amount.question != 0) {
				question.voteSum += amount.question;
				trace('rep: changing Question ${question._id.valueOf()} score to ${question.voteSum} (add ${amount.question})');
			}
			if (amount.questionOwner != null && amount.questionOwner != 0) {
				owner.points += amount.questionOwner;
				trace('rep: changing User (question owner) ${owner.email} score to ${owner.points} (add ${amount.questionOwner})');
			}
		}

		question.update(data);
		for (user in users)
			user.update(data);
	}

	function isAuthor(uid:db.helper.Ref<db.User>)
	{
		var author = ctx.loop.session.user;
		return author != null && uid.equals(author);
	}

	public function dispatch(event:Event, ?pos:haxe.PosInfos)
	{
		trace('rep: ${Type.enumConstructor(event)} from ${pos.className}::${pos.methodName}');
		switch (event) {
		case EvQstPost(q):
			magic(q, null, null, { author : 1, question : 1 });
		case EvQstFavorite(q):
			magic(q, null, null, { question : 1, questionOwner : (!isAuthor(q.user)?1:0) });
		case EvQstUnfavorite(q):
			magic(q, null, null, { question : -1, questionOwner : (!isAuthor(q.user)?-1:0) });
		case EvQstFollow(q), EvQstUnfollow(q):
			trace("rep: noop, deferred to (un)favorite, since follow implies favorite");
		case EvAnsPost(a,q):
			magic(q, a, null, { author : 2, question : 1, questionOwner : (!isAuthor(q.user)?1:0) });
		case EvAnsUpvote(a,q):
			magic(q, a, null, { answer : 1, answerOwner : (!isAuthor(a.user)?5:0), question : 1, questionOwner : (!isAuthor(q.user)?2:0) });
		case EvAnsDownvote(a,q):
			magic(q, a, null, { answer : -1, answerOwner : (!isAuthor(a.user)?-5:0), question : -1, questionOwner : (!isAuthor(q.user)?-2:0) });
		case EvCmtPost(c,a,q):
			magic(q, a, c, { answer : 1, answerOwner : (!isAuthor(a.user)?1:0), question : 1 });
		}
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

