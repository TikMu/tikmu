package route;

import mweb.http.*;
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

class BaseList extends BaseRoute {
	var view:ListView;

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(_ctx);
	}

	function cleanRawData(questions:Array<db.Question>)
	{
		var qs = [];
		for (q in questions) if (!q.deleted) {
			q = Reflect.copy(q);
			var as = [];
			for (a in q.answers) if (!a.deleted) {
				a = Reflect.copy(a);
				var cs = [];
				for (c in a.comments) if (!c.deleted) {
					cs.push(c);
				}
				a.comments = cs;
				as.push(a);
			}
			q.answers = as;
			qs.push(q);
		}
		return qs;
	}
}

class List extends BaseList {
	@openRoute
	public function any()
	{
		var qs = data.questions.find({ deleted : false }).toArray();
		qs = [ for (q in qs) if (!q.deleted) q ];

		var data = {
			questions : cleanRawData(qs),
			title : "Discover"
		};
		return Response.fromContent(new TemplateLink(data, view));
	}
}

class Favorites extends BaseList {
	public function any()
	{
		var uq = data.userQuestions.findOne({ _id : loop.session.user });
		var qds = uq != null ? [ for (qd in uq.data) if (qd.favorite) qd.question.asId() ] : [];

		var qs = data.questions.col.find({ _id : { "$in" : qds }, deleted : false }).toArray();

		var data = {
			questions : cleanRawData(cast qs),  // TODO fix $in expects array in mongodb
			title : "Favorites"
		};
		return Response.fromContent(new TemplateLink(data, view));
	}
}

class Search extends BaseList {
	@openRoute
	public function get(?args:{query:String, ?useTags:Bool})
	{
		var qry = ~/\s+/g.split(args.query);
		var qs;
		if (args.useTags) {
			qs = data.questions.col.find({ tags : { "$in" : qry }, deleted : false }).toArray();
		} else {
			var rs = [ for (s in qry) { contents : { "$regex" : s, "$options" : "ix" } } ];
			qs = data.questions.find({ "$and" : rs, deleted : false }).toArray();
		}

		var data = {
			questions : cleanRawData(cast qs),  // TODO fix $in expects array in mongodb
			title : "Search results"
		}
		return Response.fromContent(new TemplateLink(data, view));
	}

	@openRoute
	public function post(?args)
	{
		// necessary because for increased safety mweb only exposes GET
		// arguments to GET *only* requests
		return get(args);
	}
}

