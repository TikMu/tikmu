package routes.list;
import db.helper.Location;
import db.Question;
import mweb.tools.*;
import mweb.tools.TemplateLink;
import routes.ObjectId;

class ListFavoritesRoute extends BaseRoute
{	
	public function anyDefault():HttpResponse<{ qs:Array<{id:ObjectId, userID : ObjectId, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectId> }>
	{
		//TODO:
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		// this is where the magic will happen
		// qs: [ for (q in ctx.questions.find()) { user: q.user.get(ctx.db.user), contents:q.contents } ]
		// qs: [ for (q in ctx.questions.find()) q.with({ user: q.user.get(ctx.db.user) });
		
		//$type(ctx.questions.find({}));
		
		var userQuestions = ctx.userQuestions.findOne( { _id : ctx.session.user } );
		var qArr : Array<Question> = [];
		for (d in userQuestions.data)
		{
			if (d.favorite)
			{
				qArr.push(d.question.get(ctx.questions.col));
			}
		}
		
		var qs = [ for (q in qArr) { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answersCount : q.answers.length } ];
		
		return HttpResponse.fromContent(new TemplateLink({ qs : qs, authenticated : (ctx.session != null), myUser : myUser }, new ListFavoritesView()));
	}
}

@:includeTemplate("../list/list.html")
class ListFavoritesView extends erazor.macro.SimpleTemplate<{ qs:Array<{id:ObjectId, userID : ObjectId, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectId> }>
{
}
