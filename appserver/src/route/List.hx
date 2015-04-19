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
		var qs = ctx.questions.find({}).toArray();
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
		var qds = uq != null ? uq.data : [];

		var qs = [ for (qd in qds) if (qd.favorite) qd.question.get(ctx.questions.col) ];
		qs = [ for (q in qs) if (!q.deleted) q ];

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
		var qs;
		trace(args);
		if (args.useTags) {
			qs = ctx.questions.col.find({ tags : { "$in" : args.query } }).sort({ _id : 1 }).toArray();
		} else {
			var query = ~/\s+/g.split(args.query);
			var rs = [ for (s in query) { contents : { "$regex" : s, "$options" : "ix" } } ];
			trace(rs);
			qs = ctx.questions.col.find({ "$and" : rs }).toArray();
		}
		qs = [ for (q in qs) if (!q.deleted) q ];

		var data = {
			questions : qs,
			title : "Search results"
		}
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	@openRoute
	public function any(?args)
	{
		return get(args);
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

