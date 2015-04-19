package route;

import mweb.tools.*;

typedef ListViewData = {
	questions : Array<db.Question>,
	title : String,
}

@:includeTemplate("list.html")
class ListView extends erazor.macro.SimpleTemplate<ListViewData>
{
	public var ctx:Context;

	public function new(ctx)
	{
		this.ctx = ctx;
		super();
	}
}

class List extends BaseRoute
{
	var view:ListView;

	@openRoute
	public function any()
	{
		var qs = ctx.questions.find({ deleted : false }).toArray();
		qs = [ for (q in qs) if (!q.deleted) q ];

		var data = { 
			questions : qs,
			title : "Discover"
		};
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

class Favorites extends BaseRoute
{
	var view:ListView;

	public function any()
	{
		var uq = ctx.userQuestions.findOne({ _id : ctx.session.user });
		var qds = uq != null ? [ for (qd in uq.data) if (qd.favorite) qd.question.asId() ] : [];

		var qs = ctx.questions.col.find({ _id : { "$in" : qds }, deleted : false }).toArray();

		var data = {
			questions : qs,
			title : "Favorites"
		};
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

class Search extends BaseRoute
{
	var view:ListView;

	@openRoute
	public function get(?args:{query:String, ?useTags:Bool})
	{
		var qry = ~/\s+/g.split(args.query);
		var qs;
		if (args.useTags) {
			qs = ctx.questions.col.find({ tags : { "$in" : qry }, deleted : false }).toArray();
		} else {
			var rs = [ for (s in qry) { contents : { "$regex" : s, "$options" : "ix" } } ];
			qs = ctx.questions.col.find({ "$and" : rs, deleted : false }).toArray();
		}

		var data = {
			questions : qs,
			title : "Search results"
		}
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	@openRoute
	public function post(?args)
	{
		// necessary because for increased safety mweb only exposes GET
		// arguments to GET *only* requests
		return get(args);
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

