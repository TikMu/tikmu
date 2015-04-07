package routes.list;
import db.helper.Location;
import mweb.tools.*;
import routes.ObjectId;
import db.Question;

class ListRoute extends BaseRoute
{
	@openRoute
	public function anyDefault(?args:{ msg:String }):HttpResponse<ListResponse>
	{
		var myUser : Null<ObjectId> = (ctx.session.isAuthenticated()) ? ctx.session.user.get(ctx.users.col)._id : null;
		var qs = [ for (q in ctx.questions.find({})) { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answersCount : q.answers.length } ];

		return HttpResponse.fromContent(new TemplateLink({ qs : qs, msg: args != null ? args.msg : null, authenticated : (ctx.session != null), myUser : myUser }, new ListView()));
	}

	public function anyFavorites()
	{
		//TODO:
		var myUser = ctx.session.user.get(ctx.users.col)._id;

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

		return HttpResponse.fromContent(new TemplateLink({ qs : qs, msg: null, authenticated : (ctx.session != null), myUser : myUser }, new ListView()));
	}
}

typedef ListResponse = {
	qs : Array<{ id : ObjectId, userID : ObjectId, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answersCount : Int }>,
	msg : Null<String>,
	authenticated : Bool,
	myUser : Null<ObjectId>
};

@:includeTemplate("list.html")
class ListView extends erazor.macro.SimpleTemplate<ListResponse>
{
}
