package routes.ask;
import org.bsonspec.*;
import mweb.tools.*;

class AskRoute extends BaseRoute
{
	public function getDefault():HttpResponse<{}>
	{
		return HttpResponse.fromContent(new TemplateLink({}, new AskView()));
	}

	public function postDefault(args:{ data:String }):HttpResponse<Dynamic>
	{
		var q:db.Question = {
			_id : new ObjectID().bytes.toHex(),

			user : null,
			contents : args.data,
			tags : [],
			loc : { lat:-23, lon:-43, },
			voteSum : 0,
			favorites : 0,
			watchers : 0,
			solved : false,
			deleted : false,

			created : Date.now(),
			modified : Date.now(),

			//comments : [],
			answers : [],
		};

		this.ctx.questions.insert(q);
		return HttpResponse.empty().redirect('/');
	}
}

@:includeTemplate("ask.html")
class AskView extends erazor.macro.SimpleTemplate<{}>
{
}
