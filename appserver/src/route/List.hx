package route;

import mweb.http.*;
import mweb.tools.*;
using db.QuestionTools;

typedef QuestionSummaryData = {
	> db.Question,
	state : {
		?favorite : Bool,
		?following : Bool
	}
}

typedef ListViewData = {
	questions : Array<QuestionSummaryData>,
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

	function postProcess(questions:Array<db.Question>):Array<QuestionSummaryData>
	{
		var qs = [];
		for (q in questions) if (!q.deleted) {
			var q:QuestionSummaryData = cast q.clean();
			qs.push(q);
			q.state = loop.session.isAuthenticated() ? q.getQuestionMonitoringState(_ctx) : cast {};
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
			questions : postProcess(qs),
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
			questions : postProcess(cast qs),  // TODO fix $in expects array in mongodb
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
			questions : postProcess(cast qs),  // TODO fix $in expects array in mongodb
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

