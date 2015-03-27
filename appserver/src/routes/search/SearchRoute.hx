package routes.search;
import db.helper.Location;
import db.Question;
import mweb.tools.HttpResponse;
import mweb.tools.TemplateLink;
import org.bsonspec.ObjectID;
import routes.BaseRoute;

using Lambda;
 
class SearchRoute extends BaseRoute
{
	@openRoute
	public function anyDefault(?args:{searchString : Array<String>, ?tagSearch : Bool}) : HttpResponse<{ qs:Array<{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectID> }>
	{
		var myUser : Null<ObjectID> = (ctx.session.isAuthenticated()) ? ctx.session.user.get(ctx.users.col)._id : null;
		
		var q : Array<Question> = [];
		if (args.tagSearch)
		{
			for (s in args.searchString)
			{
				var results = ctx.questions.col.find( { tags : s } );
				//var results = ctx.questions.find( { tags : s } );
				for (r in results)
				{
					if (q.indexOf(r) == -1)
						q.push(r);
				}
			}
		}
		else
		{
			for (s in args.searchString)
			{
				var results = ctx.questions.find( { contents : {"$regex": s, "$options": "ix"} } );
				for (r in results)
				{
					if (q.indexOf(r) == -1)
						q.push(r);
				}
			}
		}		
		
		q.sort(function(a, b) {
			var aid = a._id.toLowerCase();
			var bid = b._id.toLowerCase();
			if (aid < bid)
				return -1;
			if (aid > bid)
				return 1;
			return 0;
		});
		
		var qs = [ for (q in ctx.questions.find({})) { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answersCount : q.answers.length } ];
		
		return HttpResponse.fromContent(new TemplateLink({ qs : qs, authenticated : (ctx.session != null), myUser : myUser }, new SearchView()));
	}
}

@:includeTemplate("../list/list.html")
class SearchView extends erazor.macro.SimpleTemplate<{ qs:Array<{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectID> }>
{
}