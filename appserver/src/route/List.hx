package route;

import mweb.tools.*;

typedef ListViewData = {
	questions : Array<db.Question>,
	title : String,
}

@:includeTemplate("list.html")
class ListView extends BaseView<ListViewData> {
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
}

class List extends BaseRoute
{
	var view:ListView;

	@openRoute
	public function any()
	{
		var qs = data.questions.find({ deleted : false }).toArray();
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
		view = new ListView(_ctx);
	}
}

class Favorites extends BaseRoute
{
	var view:ListView;

	public function any()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		var qds = uq != null ? [ for (qd in uq.data) if (qd.favorite) qd.question.asId() ] : [];

		var qs = data.questions.col.find({ _id : { "$in" : qds }, deleted : false }).toArray();

		var data = {
			questions : qs,
			title : "Favorites"
		};
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(_ctx);
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
			qs = data.questions.col.find({ tags : { "$in" : qry }, deleted : false }).toArray();
		} else {
			var rs = [ for (s in qry) { contents : { "$regex" : s, "$options" : "ix" } } ];
			qs = data.questions.col.find({ "$and" : rs, deleted : false }).toArray();
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
		view = new ListView(_ctx);
	}
}

