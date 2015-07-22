package route;

import db.Question;
import mweb.tools.*;
import mweb.http.*;
import route.Question;

class SomeAnswer extends BaseRoute {
	var question:db.Question;
	var answer:db.Answer;

	@openRoute
	public function any()
	{
		return new Response().redirect('/question/${question._id.valueOf()}#${answer._id.valueOf()}');
	}

	public function postComment(args:{ comment:String })
	{
		var cmt = {
			_id : new ObjectId(),
			user : loop.session.user,
			contents : args.comment,
			created : loop.now,
			modified : loop.now,
			deleted : false
		};
		answer.comments.push(cmt);
		data.questions.update({ _id : question._id }, question);
		_ctx.reputation.update({ value : RPostComment, target : RComment(cmt, answer, question) });
		return new Response().redirect('/question/${question._id.valueOf()}#${cmt._id.valueOf()}');
	}

	public function postUpvote()
	{
		var uq = data.userActions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = {
				_id : loop.session.user,
				onQuestion : [],
				onAnswer : []
			}

		var uqa = Lambda.find(uq.onAnswer, function (x) return x.answer.equals(answer._id));
		if (uqa == null) {
			uqa = {
				answer : answer._id,
				vote : 0
			};
			uq.onAnswer.push(uqa);
		}

		if (uqa.vote < 1) {
			uqa.vote++;
			data.userActions.update({ _id : loop.session.user }, uq, true);
			data.questions.update({ _id : question._id }, question);
			_ctx.reputation.update({ value : RUpvoteAnswer, target : RAnswer(answer, question) });
		}

		var state = {
			vote : uqa.vote
		};
		return Response.fromContent(serialize(state));
	}

	public function postEdit(args:{ updated:String })
	{
		if (!answer.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		answer.contents = args.updated;
		answer.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new Response().redirect('/question/${question._id.valueOf()}#${answer._id.valueOf()}');
	}

	public function postDelete()
	{
		if (!answer.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		answer.deleted = true;
		answer.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new Response().redirect('/question/${question._id.valueOf()}');
	}


	public function new(ctx, question, answer)
	{
		super(ctx);
		this.question = question;
		this.answer = answer;
	}
}

class Answer extends BaseRoute {
	@openRoute
	public function anyDefault(d:mweb.Dispatcher<Response<Dynamic>>, id:ObjectId):Response<Dynamic>
	{
		var question = data.questions.findOne({
			answers : {"$elemMatch":{
				_id : id,
				deleted : false
			}},
			deleted : false
		});
		if (question == null)
			return new Response().setStatus(NotFound);

		var answer = Lambda.find(question.answers, function (x) return x._id.equals(id));
		return d.dispatch(new SomeAnswer(_ctx, question, answer));
	}
}

