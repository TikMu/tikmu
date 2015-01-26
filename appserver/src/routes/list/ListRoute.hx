package routes.list;
import mweb.tools.*;

class ListRoute extends BaseRoute
{
	@openRoute
	public function anyDefault():HttpResponse<{ qs:Array<db.Question> }>
	{
		// this is where the magic will happen
		return HttpResponse.fromContent(new TemplateLink({ qs:ctx.questions.find({}).toArray() }, new ListView()));
	}
}

@:includeTemplate("list.html")
class ListView extends erazor.macro.SimpleTemplate<{ qs:Array<db.Question> }>
{
}
