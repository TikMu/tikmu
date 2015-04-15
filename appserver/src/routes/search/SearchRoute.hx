package routes.search;

import db.Question;
import db.helper.Location;
import mweb.tools.HttpResponse;
import mweb.tools.TemplateLink;
import routes.BaseRoute;
import routes.ObjectId;
import routes.list.ListRoute;

using Lambda;

class SearchRoute extends BaseRoute
{
	@openRoute
	public function anyDefault(?args:{searchString : Array<String>, ?tagSearch : Bool}) : HttpResponse<ListResponse>
	{
		var myUser : Null<ObjectId> = (ctx.session.isAuthenticated()) ? ctx.session.user.get(ctx.users.col)._id : null;

		var q:Array<Question>;
		if (args.tagSearch) {
			q = ctx.questions.col.find({ tags : { "$in" : args.searchString } }).sort({ _id : 1 }).array();
		} else {
			var rs = [for (s in args.searchString) { "$regex" : s, "$options" : "ix" }];
			q = ctx.questions.col.find({ contents : { "$in" : rs } }).sort({ _id : 1 }).array();
		}

		var qs = [ for (q in ctx.questions.find({})) { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answersCount : q.answers.length } ];

		return HttpResponse.fromContent(new TemplateLink({ qs : qs, msg:null, authenticated : (ctx.session != null), myUser : myUser }, new routes.list.ListRoute.ListView(ctx)));
	}
}

// @:includeTemplate("../list/list.html")
// class SearchView extends erazor.macro.SimpleTemplate<{ qs:Array<{id:ObjectId, userID : ObjectId, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectId> }>
// {
// }

