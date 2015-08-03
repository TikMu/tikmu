package route;

import mweb.http.*;
import mweb.tools.*;
import effect.Event;
using db.QuestionTools;
using db.UserActionsTools;
using db.UserTools;

typedef SomeQuestionViewData = {
	question : db.Question,
	?state : {
		favorite:Bool,
		following:Bool
	},
	?votes : Array<Int>
}

@:includeTemplate("question.html")
class SomeQuestionView extends BaseView<SomeQuestionViewData> {}

class SomeQuestion extends BaseRoute {
	var question:db.Question;
	var view:SomeQuestionView;

	function postProcess(question:db.Question):SomeQuestionViewData
	{
		var ua = loop.session.isAuthenticated() ? loop.session.user.getUserActions(data) : null;
		var d:SomeQuestionViewData = { question : question.clean() };
		if (loop.session.isAuthenticated()) {
			d.state = ua.questionSummary(question._id);
			d.votes = [for (a in question.answers) {
				var s = ua.answerSummary(a);
				if (s != null)
					s.vote;
				else
					0;
			}];
		}
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
		data.questions.update({ _id : question._id }, {"$push":{ answers : ans }} );
		_ctx.dispatchEvent(EvAnsPost(ans, question));
		return new Response().redirect('/question/${question._id.valueOf()}#${ans._id.valueOf()}');
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
			events = [EvQstUnfavorite(question)];
			if (uqq.following) {
				uqq.following = false;
				events[1] = EvQstUnfollow(question);
			}
		} else {
			trace('favorite=on');
			uqq.favorite = true;
			events = [EvQstFavorite(question)];
		}

		data.userActions.update({ _id : loop.session.user }, uq, true);  // TODO atomic

		for (e in events)
			_ctx.dispatchEvent(e);

		var state = {
			favorite : uqq.favorite,
			following : uqq.following
		};
		return serialize(state);
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
				favorite : false,
				following : false
			};
			uq.onQuestion.push(uqq);
		}

		var events;
		if (uqq.following) {
			trace('following=off');
			uqq.following = false;
			events = [EvQstUnfollow(question)];
		} else {
			trace('following=on (implies favorite=on)');
			uqq.following = true;
			events = [EvQstFollow(question)];
			if (!uqq.favorite) {
				uqq.favorite = true;
				events[1] = EvQstFavorite(question);
			}
		}

		data.userActions.update({ _id : loop.session.user }, uq, true);  // TODO atomic

		for (e in events)
			_ctx.dispatchEvent(e);

		var state = {
			favorite : uqq.favorite,
			following : uqq.following
		};
		return serialize(state);
	}

	public function postEdit(args:{ updated:String })
	{
		if (!question.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		question.contents = args.updated;
		question.modified = loop.now;
		data.questions.update({ _id : question._id }, {
			contents : question.contents,
			modified : question.modified
		});
		return new Response().redirect('/question/${question._id.valueOf()}');
	}

	public function postDelete()
	{
		if (!question.user.equals(loop.session.user))
			return new Response().setStatus(Unauthorized);

		question.deleted = true;
		question.modified = loop.now;
		data.questions.update({ _id : question._id }, {
			deleted : question.deleted,
			modified : question.modified
		});
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

