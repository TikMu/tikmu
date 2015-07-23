package route;

import mweb.http.*;
import mweb.tools.*;
using db.QuestionTools;
using db.UserActionsTools;
using db.UserTools;

typedef QuestionSummaryData = {
	> db.Question,
	?state : {
		favorite : Bool,
		following : Bool
	}
}

typedef ListViewData = {
	questions : Array<QuestionSummaryData>,
	title : String,
}

@:includeTemplate("list.html")
class ListView extends BaseView<ListViewData> {}

class BaseList extends BaseRoute {
	var view:ListView;

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(_ctx);
	}

	function balancedOrder(a:db.Question, b:db.Question)
	{
		var days = (b.created.getTime() - a.created.getTime())/1000/3600/24;
		var points = (b.voteSum - a.voteSum)/100;
		var score = days + points;
		return score >= 0 ? 1 : -1;
	}

	function recenticityOrder(a:db.Question, b:db.Question)
	{
		var score = b.created.getTime() - a.created.getTime();
		return score >= 0 ? 1 : -1;
	}

	function postProcess(questions:Array<db.Question>):Array<QuestionSummaryData>
	{
		var ua = loop.session.isAuthenticated() ? loop.session.user.getUserActions(data) : null;

		var qs = [];
		for (q in questions) if (!q.deleted) {
			var q:QuestionSummaryData = cast q.clean();
			if (loop.session.isAuthenticated() )
				q.state = ua.questionSummary(q._id);
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
		qs.sort(balancedOrder);

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
		var uq = data.userActions.findOne({ _id : loop.session.user });
		var qds = uq != null ? [ for (qd in uq.onQuestion) if (qd.favorite) qd.question.asId() ] : [];

		var qs = data.questions.col.find({ _id : { "$in" : qds }, deleted : false }).toArray();
		qs.sort(recenticityOrder);

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
		qs.sort(balancedOrder);

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

