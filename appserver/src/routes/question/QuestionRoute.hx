package routes.question;
import db.helper.Location;
import mweb.tools.HttpResponse.HttpResponse;
import mweb.tools.TemplateLink;
import org.bsonspec.*;
import mweb.tools.*;
import org.bsonspec.ObjectID;

class QuestionRoute extends BaseRoute
{
	@openRoute
	public function getDefault(id:String):HttpResponse<{ data:{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>, answers : Array<{ userID : ObjectID, deleted : Bool, loc : Location, voteSum : Int, date : Date, contents : String, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>}>}, authenticated : Bool, myUser : Null<ObjectID>, username : String, userpoint : Int, isFav : Bool, isFollowing : Bool }>
	{
		var q = this.ctx.questions.findOne( { _id : id } );
		var myUser : Null<ObjectID> = (ctx.session.isAuthenticated()) ? ctx.session.user.get(ctx.users.col)._id : null;
		
		if ( q == null )
			return HttpResponse.fromContent(new TemplateLink({ data:null, authenticated : ctx.session.isAuthenticated(), myUser : myUser, username : '', userpoint : 0, isFav : false, isFollowing : false }, function(_) return '<h1>Invalid question</h1>'));

		var user = q.user.get(ctx.users.col);
			
		var username = user.name;		
		var userpoint = user.points;
		
		var isFav = false;
		var isFollowing = false;
		
		var uq = ctx.userQuestions.findOne( { _id : user._id } );
		if (uq != null)
		{
			//TODO: Change searchType for $elemMatch
			for (d in uq.data)
			{
				if (d.question.get(ctx.questions.col) == q)
				{
					if (d.favorite)
						isFav = true;
					if (d.following)
						isFollowing = true;
					break;
				}
			}
		}
			
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, comments : [for(c in q.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}], answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : ctx.session.isAuthenticated(), myUser : myUser, username : username, userpoint : userpoint, isFav : isFav, isFollowing : isFollowing }, new QuestionView()));
	}

	public function postAnswer(id:String, args:{ answer:String }):HttpResponse<Dynamic>
	{
		var q = this.ctx.questions.findOne({ _id : id });
		if ( q == null )
			return HttpResponse.fromContent(
					new TemplateLink({ q:null }, function(_) return '<h1>Invalid question id $id</h1>'));

		q.answers.push({
			deleted: false,
			user: ctx.session.user,
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
	
	public function postComment(id : String, ?answerIndex : Int, args : { comment : String } ) : HttpResponse<Dynamic>
	{
		var q = this.ctx.questions.findOne( { _id : id } );
		if (q == null)
			return HttpResponse.fromContent(
					new TemplateLink( { q:null }, function(_) return '<h1>Invalid question id $id</h1>'));
					
		if (answerIndex == null)
		{
			q.comments.push( {
				user : ctx.session.user,
				contents : args.comment,
				created : Date.now(),
				modified : Date.now(),
				deleted : false
			});
			
			this.ctx.questions.update( { _id : id }, q);
			return HttpResponse.empty().redirect('/question/$id');
		}
		else
		{
			var ans = q.answers[answerIndex];
			if (ans == null)
				return HttpResponse.fromContent(
						new TemplateLink( { q:null }, function(_) return '<h1>Invalid answer index $answerIndex</h1>'));
						
			ans.comments.push( {
				user : ctx.session.user,
				contents : args.comment,
				created : Date.now(),
				modified : Date.now(),
				deleted : false
			});
			
			this.ctx.questions.update( { _id : id }, q);
			return HttpResponse.empty().redirect('/question/$id');
		}
	}
}

@:includeTemplate("question.html")
class QuestionView extends erazor.macro.SimpleTemplate<{ data:{id : String, userID : ObjectID, userName : String, contents : String, tags : Array<String>, loc : db.helper.Location, voteSum : Int, favorites : Int, watchers : Int, date : Date, solved : Bool, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>, answers : Array<{ userID : ObjectID, deleted : Bool, loc : Location, voteSum : Int, date : Date, contents : String, comments : Array<{userID : ObjectID, contents : String, date:Date, deleted : Bool}>}>}, authenticated : Bool, myUser : Null<ObjectID>, username : String, userpoint : Int, isFav : Bool, isFollowing : Bool}>
{
}

