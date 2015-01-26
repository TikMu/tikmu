package routes.question;
import org.bsonspec.*;
import mweb.tools.*;

class QuestionRoute extends BaseRoute
{
	@openRoute
	public function getDefault(id:String):HttpResponse<{ q:db.Question }>
	{
		var q = this.ctx.questions.findOne({ _id : id });
		if ( q == null )
			return HttpResponse.fromContent(new TemplateLink({ q:null }, function(_) return '<h1>Invalid question</h1>'));

		return HttpResponse.fromContent(new TemplateLink({ q: q }, new QuestionView()));
	}

	public function postAnswer(id:String, args:{ answer:String }):HttpResponse<Dynamic>
	{
		var q = this.ctx.questions.findOne({ _id : id });
		if ( q == null )
			return HttpResponse.fromContent(
					new TemplateLink({ q:null }, function(_) return '<h1>Invalid question id $id</h1>'));

		q.answers.push({
			deleted: false,
			user: null,
			contents: args.answer,
			loc: { lat: -23, lon: -43 },
			voteSum: 0,

			created: Date.now(),
			modified: Date.now(),

			comments: []
		});

		this.ctx.questions.update({ _id : id }, q);
		return HttpResponse.empty().redirect('/question/$id');
	}
}

@:includeTemplate("question.html")
class QuestionView extends erazor.macro.SimpleTemplate<{ q:db.Question }>
{
}

