package routes.list;
import db.helper.Location;
import mweb.tools.*;
import org.bsonspec.ObjectID;

class ListRoute extends BaseRoute
{
	@openRoute
	public function anyDefault():HttpResponse<{ qs:Array<{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectID> }>
	{
		var myUser : Null<ObjectID> = (ctx.session.isAuthenticated()) ? ctx.session.user.get(ctx.users.col)._id : null;
		// this is where the magic will happen
		// qs: [ for (q in ctx.questions.find()) { user: q.user.get(ctx.db.user), contents:q.contents } ]
		// qs: [ for (q in ctx.questions.find()) q.with({ user: q.user.get(ctx.db.user) });
		
		//$type(ctx.questions.find({}));
		var qs = [ for (q in ctx.questions.find({})) { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answersCount : q.answers.length } ];
		
		return HttpResponse.fromContent(new TemplateLink({ qs : qs, authenticated : (ctx.session != null), myUser : myUser }, new ListView()));
	}
}

@:includeTemplate("list.html")
class ListView extends erazor.macro.SimpleTemplate<{ qs:Array<{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int}>, authenticated : Bool, myUser : Null<ObjectID> }>
{
}
