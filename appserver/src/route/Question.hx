package route;

import mweb.http.*;
import mweb.tools.*;
import reputation.Event;
using db.QuestionTools;

typedef SomeQuestionViewData = {
	question : db.Question,
	state : {
		?favorite:Bool,
		?following:Bool
	}
}

@:includeTemplate("question.html")
class SomeQuestionView extends BaseView<SomeQuestionViewData> {}

class SomeQuestion extends BaseRoute {
	var question:db.Question;
	var view:SomeQuestionView;

	function postProcess(question:db.Question):SomeQuestionViewData
	{
		var d:SomeQuestionViewData = { question : question.clean(), state : {} };
		d.state = loop.session.isAuthenticated() ? question.getQuestionMonitoringState(_ctx) : cast {};
		return d;
	}

	@openRoute
	public function any()
	{
		var data = postProcess(question);
		return Response.fromContent(new TemplateLink(data, view));
	}

	public function postAnswer(args:{ answer:String })
	{
		var ans = {
			_id : new ObjectId(),
			deleted : false,
			user : loop.session.user,
			contents : args.answer,
			loc : {
				lat : 90.*(1 - 2*Math.random()),  // FIXME
				lon : 180.*(1 - 2*Math.random())  // FIXME
			},
			voteSum : 0,
			created : loop.now,
			modified : loop.now,
			comments : []
		};
		question.answers.push(ans);
		data.questions.update({ _id : question._id }, question);
		_ctx.reputation.update({ value : RPostAnswer, target : RAnswer(ans, question) });
		return new Response().redirect('/question/${question._id.valueOf()}#${ans._id.valueOf()}');
	}

	public function getState()
	{
		var state = question.getQuestionMonitoringState(_ctx);
		return Response.fromContent(serialize(state));
	}

	public function postFavorite()
	{
		var uq = data.userActions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = {
				_id : loop.session.user,
				onQuestion : [],
				onAnswer : []
			}

		var uqq = Lambda.find(uq.onQuestion, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uqq = {
				question : question._id,
				favorite : false,
				following : false
			};
			uq.onQuestion.push(uqq);
		}

		var events;
		if (uqq.favorite) {
			trace('favorite=off (implies following=off)');
			uqq.favorite = false;
			events = [RUnfavoriteQuestion];
			if (uqq.following) {
				uqq.following = false;
				events[1] = RUnfollowQuestion;
			}
		} else {
			trace('favorite=on');
			uqq.favorite = true;
			events = [RFavoriteQuestion];
		}

		data.userActions.update({ _id : loop.session.user }, uq, true);

		for (e in events)
			_ctx.reputation.update({ value : e, target : RQuestion(question) });

		var state = {
			favorite : uqq.favorite,
			following : uqq.following
		};
		return Response.fromContent(serialize(state));
	}

	public function postFollow()
	{
		var uq = data.userActions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = {
				_id : loop.session.user,
				onQuestion : [],
				onAnswer : []
			}

		var uqq = Lambda.find(uq.onQuestion, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uqq = {
				question : question._id,
				favorite : true,  // spec (p. 14)
				following : true
			};
			uq.onQuestion.push(uqq);
		}

		var events;
		if (uqq.following) {
			trace('following=off');
			uqq.following = false;
			events = [RUnfollowQuestion];
		} else {
			trace('following=on (implies favorite=on)');
			uqq.following = true;
			events = [RFollowQuestion];
			if (!uqq.favorite) {
				uqq.favorite = true;
				events[1] = RFavoriteQuestion;
			}
		}

		data.userActions.update({ _id : loop.session.user }, uq, true);

		for (e in events)
			_ctx.reputation.update({ value : e, target : RQuestion(question) });

		var state = {
			favorite : uqq.favorite,
			following : uqq.following
		};
		return Response.fromContent(serialize(state));
	}

	public function postEdit(args:{ updated:String })
	{
		if (!question.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		question.contents = args.updated;
		question.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new Response().redirect('/question/${question._id.valueOf()}');
	}

	public function postDelete()
	{
		if (!question.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		question.deleted = true;
		question.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new Response().redirect('/');
	}

	public function new(ctx, question)
	{
		super(ctx);
		this.question = question;
		view = new SomeQuestionView(ctx);
	}
}

class Question extends BaseRoute {

	@openRoute
	public function anyDefault(d:mweb.Dispatcher<Response<Dynamic>>, id:ObjectId)
	{
		var question = data.questions.findOne({
			_id : id,
			deleted : false
		});
		var ret:Response<Dynamic>;
		if (question == null)
			ret = new Response().setStatus(NotFound);
		else
			ret = d.dispatch(new SomeQuestion(_ctx, question));
		return ret;
	}

}

