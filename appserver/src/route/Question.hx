package route;

import mweb.tools.*;

typedef SomeQuestionViewData = {
}

@:includeTemplate("question.html")
class SomeQuestionView extends BaseView<SomeQuestionViewData> {
	function getUser()
	{
	}
}

class SomeQuestion extends BaseRoute {
	var question:db.Question;
	var view:SomeQuestionView;

	@openRoute
	public function any()
	{
		return new routes.question.QuestionRoute(_ctx).getDefault(question._id);
	}

	public function getState()
	{
		var uqq = null;

		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		if (uq != null)
			uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));

		var data = if (uqq != null) {
			votes : uqq.votes,
			favorite : uqq.favorite,
			following : uqq.following
		} else {
			votes : [],
			favorite : false,
			following : false
		}

		var ret = new HttpResponse();
		ret.setContent(new TemplateLink(data, haxe.Json.stringify.bind(_)));
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
			trace("favorite on");
			uq.data.push({
				question : question._id,
				votes : [],
				favorite : true,
				following : false  // spec (p. 14)
			});
		} else {
			trace("favorite " + (uqq.favorite ? "off" : "on"));
			uqq.favorite = !uqq.favorite;
			if (!uqq.favorite)
				uqq.following = false;  // spec (p. 14)
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		return new HttpResponse().setStatus(NoContent);
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
			trace("following on");
			uq.data.push({
				question : question._id,
				votes : [],
				favorite : true,  // spec (p. 14)
				following : true
			});
		} else {
			trace("following " + (uqq.following ? "off" : "on"));
			uqq.following = !uqq.following;
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		return new HttpResponse().setStatus(NoContent);
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
	public function anyDefault(d:mweb.Dispatcher<HttpResponse<Dynamic>>, id:ObjectId)
	{
		var question = data.questions.findOne({ _id : id });
		var ret:HttpResponse<Dynamic>;
		if (question == null)
			ret = new HttpResponse().setStatus(NotFound);
		else
			ret = d.dispatch(new SomeQuestion(_ctx, question));
		return ret;
	}

}

