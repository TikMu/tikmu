package route;

import mweb.tools.*;

typedef QuestionViewData = {
}

@:includeTemplate("question.html")
class QuestionView extends BaseView<QuestionViewData> {}

class SomeQuestion extends BaseRoute {
	var question:db.Question;

	@openRoute
	public function any()
	{
		return new routes.question.QuestionRoute(_ctx).getDefault(question._id);
	}

	public function anyFavorite()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = { 
				_id : loop.session.user,
				data : []
			}

		var uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uq.data.push({
				question : question._id,
				votes : [],
				favorite : true,
				following : false  // spec (p. 14)
			});
		} else {
			uqq.favorite = !uqq.favorite;
			if (!uqq.favorite)
				uqq.following = false;  // spec (p. 14)
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		return new HttpResponse().setStatus(NoContent);
	}

	public function anyFollow()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		if (uq == null)
			uq = { 
				_id : loop.session.user,
				data : []
			}

		var uqq = Lambda.find(uq.data, function (x) return x.question.equals(question._id));
		if (uqq == null) {
			uq.data.push({
				question : question._id,
				votes : [],
				favorite : true,  // spec (p. 14)
				following : true
			});
		} else {
			uqq.following = !uqq.following;
		}

		data.userQuestions.update({ _id : loop.session.user }, uq, true);
		return new HttpResponse().setStatus(NoContent);
	}

	public function new(ctx, question)
	{
		super(ctx);
		this.question = question;
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

