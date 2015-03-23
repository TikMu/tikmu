package routes.question;
import db.helper.Location;
import mweb.tools.TemplateLink;
import org.bsonspec.*;
import mweb.tools.*;
import org.bsonspec.ObjectID;

class QuestionRoute extends BaseRoute
{
	@openRoute
	public function getDefault(id:String):HttpResponse<{ data:{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answers : Array<{ userID : ObjectID, deleted : Bool, loc : Location, voteSum : Int, date : Date, contents : String, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>}>}, authenticated : Bool, myUser : Null<ObjectID> }>
	{
		var q = this.ctx.questions.findOne( { _id : id } );
		var myUser : Null<ObjectID> = (ctx.session == null) ? null : ctx.session.user.get(ctx.users.col)._id;
		
		if ( q == null )
			return HttpResponse.fromContent(new TemplateLink({ data:null, authenticated : (ctx.session != null), myUser : myUser }, function(_) return '<h1>Invalid question</h1>'));

		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}

	public function postAnswer(id:String, args:{ answer:String }):HttpResponse<Dynamic>
	{
		var q = this.ctx.questions.findOne({ _id : id });
		if ( q == null )
			return HttpResponse.fromContent(
					new TemplateLink({ q:null }, function(_) return '<h1>Invalid question id $id</h1>'));

		q.answers.push({
			deleted: false,
			user: null,
			contents: args.answer,
			loc: { lat: -23, lon: -43 },
			voteSum: 0,

			created: Date.now(),
			modified: Date.now(),

			comments: []
		});

		this.ctx.questions.update({ _id : id }, q);
		return HttpResponse.empty().redirect('/question/$id');
	}
}

@:includeTemplate("question.html")
class QuestionView extends erazor.macro.SimpleTemplate<{ data:{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, answers : Array<{ userID : ObjectID, deleted : Bool, loc : Location, voteSum : Int, date : Date, contents : String, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>}>}, authenticated : Bool, myUser : Null<ObjectID>}>
{
}

