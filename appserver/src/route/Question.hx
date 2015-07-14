package route;

import mweb.http.*;
import mweb.tools.*;
using db.QuestionTools;

typedef SomeQuestionViewData = {
	question : db.Question
}

@:includeTemplate("question.html")
class SomeQuestionView extends BaseView<SomeQuestionViewData> {
	function getUser(id)
	{
		var u = ctx.data.users.col.findOne({ _id : id });
		if (u == null)
			return null;
		return {
			email : u.email,
			name : u.name
		}
	}

	function getPrettyDelta(date:Date)
	{
		var delta = ctx.loop.now.getTime() - date.getTime();
		var keys = ["m", "h", "d", "w"];

		var d = Std.int(1e-3*delta/60);
		var i = 1;
		for (div in [60, 24, 7]) {
			var _d = Std.int(d/div);
			if (_d == 0)
				break;
			d = _d;
			i++;
		}
		return '${d}${keys[i-1]}';
	}
}

class SomeQuestion extends BaseRoute {
	var question:db.Question;
	var view:SomeQuestionView;

	@openRoute
	public function any()
	{
		var data = { question : question };
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
		return new Response().redirect('/question/${question._id.valueOf()}#${ans._id.valueOf()}');
	}

	public function getState()
	{
		var state = question.getQuestionMonitoringState(_ctx);

		var ret = new Response();
		ret.setContent(new TemplateLink(state, haxe.Json.stringify.bind(_)));
		return ret;
	}

	public function postFavorite()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = {
				_id : loop.session.user,
				data : []
			}

		var uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uqq = {
				question : question._id,
				votes : [],
				favorite : false,
				following : false
			};
			uq.data.push(uqq);
		}

		if (uqq.favorite) {
			trace('favorite=off (implies following=off)');
			uqq.favorite = false;
			question.favorites--;
			if (uqq.following) {
				uqq.following = false;
				question.watchers--;
			}
		} else {
			trace('favorite=on');
			uqq.favorite = true;
			question.favorites++;
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		data.questions.update({ _id : question._id }, question);
		return new Response().setStatus(NoContent);
	}

	public function postFollow()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = {
				_id : loop.session.user,
				data : []
			}

		var uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uqq = {
				question : question._id,
				votes : [],
				favorite : true,  // spec (p. 14)
				following : true
			};
			uq.data.push(uqq);
		}

		if (uqq.following) {
			trace('following=off');
			uqq.following = false;
			question.watchers--;
		} else {
			trace('following=on (implies favorite=on)');
			uqq.following = true;
			question.watchers++;
			uqq.favorite = true;
			question.favorites++;
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		data.questions.update({ _id : question._id }, question);
		return new Response().setStatus(NoContent);
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

