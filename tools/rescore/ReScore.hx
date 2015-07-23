import org.mongodb.*;

class ReScore {
	static function fakeSession(userId:db.helper.Ref<db.User>)
	{
		return new db.Session(null, userId, 1e9, null);
	}

	static function main()
	{
		var db = new Mongo().tikmu;
		var data = new StorageContext(db);
		var fakeLoop = {
			session : null
		};
		(fakeLoop.session:db.Session);
		var fakeCtx:Context = cast { data : data, loop : fakeLoop };
		var rep = new reputation.Handler(fakeCtx);

		trace('clearing everything');
		for (q in data.questions.find({})) {
			q.voteSum = 0;
			for (a in q.answers)
				a.voteSum = 0;
			data.questions.update({ _id : q._id }, q);
		}
		data.users.update({}, {"$set":{ points : 0 }}, false, true);

		trace('computing: adding questions');
		for (q in data.questions.find({})) {
			fakeLoop.session = fakeSession(q.user);
			rep.update({ value : RPostQuestion, target : RQuestion(q) });
		}

		trace('computing: adding answers');
		for (q in data.questions.find({})) {
			for (a in q.answers) {
				fakeLoop.session = fakeSession(a.user);
				rep.update({ value : RPostAnswer, target : RAnswer(a, q) });
			}
		}

		trace('computing: adding comments');
		for (q in data.questions.find({})) {
			for (a in q.answers) {
				for (c in a.comments) {
					fakeLoop.session = fakeSession(c.user);
					rep.update({ value : RPostComment, target : RComment(c, a, q) });
				}
			}
		}

		trace('computing: adding favorites, followers and (TODO) votes');
		for (uq in data.userActions.find({})) {
			fakeLoop.session = fakeSession(uq._id);
			for (uqq in uq.onQuestion) {
				var q = uqq.question.get(data.questions.col);
				if (!uq._id.equals(q.user)) {
				    if (uqq.favorite)
					    rep.update({ value : RFavoriteQuestion, target : RQuestion(q) });
				    if (uqq.following)
					    rep.update({ value : RFavoriteQuestion, target : RQuestion(q) });
				}
			}
			for (uqa in uq.onAnswer) {
				var q = data.questions.findOne({ answers : { "$elemMatch" : { _id : uqa.answer } } });
				var a = Lambda.find(q.answers, function (x) return x._id.equals(uqa.answer));
				if (uqa.vote == 0)
					continue;
				rep.update({ value : (uqa.vote > 0 ? RUpvoteAnswer : RDownvoteAnswer), target : RAnswer(a, q) });
			}
		}
	}
}

