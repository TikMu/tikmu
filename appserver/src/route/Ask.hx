package route;

import mweb.http.*;
import mweb.tools.*;

@:includeTemplate("ask.html")
class AskView extends BaseView<Void> {
}

class Ask extends BaseRoute {
	var view:AskView;

	public function get()
	{
		return Response.fromContent(new TemplateLink(null, view));
	}

	public function post(args:{ question:String, tags:String })
	{
		var q = {
			_id : new ObjectId(),

			user : loop.session.user,
			contents : args.question,
			tags : ~/\s+/g.split(args.tags),
			loc : {
				lat : 90.*(1 - 2*Math.random()),  // FIXME
				lon : 180.*(1 - 2*Math.random())  // FIXME
			},
			voteSum : 0,
			favorites : 0,
			watchers : 0,

			deleted : false,
			created : loop.now,
			modified : loop.now,
			solved : false,

			answers : []
		};
		data.questions.insert(q);
		_ctx.reputation.handle({ value : RPostQuestion, target : RQuestion(q) });
		return new Response().redirect('/question/${q._id.valueOf()}/');
	}

	public function new(ctx)
	{
		super(ctx);
		view = new AskView(ctx);
	}
}

