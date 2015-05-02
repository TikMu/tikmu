package routes.question;

import db.helper.Location;
import mweb.tools.*;
import mweb.tools.HttpResponse.HttpResponse;
import mweb.tools.TemplateLink;

class QuestionRoute extends BaseRoute
{
	@openRoute
	public function getDefault(id:ObjectId):HttpResponse<QuestionResult>
	{
		var q = data.questions.findOne( { _id : id } );
		var myUser : Null<ObjectId> = (loop.session.isAuthenticated()) ? loop.session.user.get(data.users.col)._id : null;

		if ( q == null )
			return HttpResponse.fromContent(new TemplateLink({ data:null, authenticated : loop.session.isAuthenticated(), myUser : myUser, username : '', userpoint : 0, isFav : false, isFollowing : false }, function(_) return '<h1>Invalid question</h1>'));

		var user = q.user.get(data.users.col);

		var username = user.name;
		var userpoint = user.points;

		var isFav = false;
		var isFollowing = false;

		var uq = data.userQuestions.findOne( { _id : user._id } );
		if (uq != null)
		{
			//TODO: Change searchType for $elemMatch
			for (d in uq.data)
			{
				if (d.question.get(data.questions.col) == q)
				{
					if (d.favorite)
						isFav = true;
					if (d.following)
						isFollowing = true;
					break;
				}
			}
		}

		return HttpResponse.fromContent(new TemplateLink(toResult(q, this, { myUser:myUser, username:username, userpoint:userpoint, isFav:isFav, isFollowing:isFollowing }), new QuestionView()));
	}

	public function deleteDefault(id:ObjectId):HttpResponse<Dynamic>
	{
		var myUser = loop.session.user.get(data.users.col);
		var q = data.questions.findOne( { _id : id } );
		if (q == null)
			return HttpResponse.empty().setStatus(NotFound);

		if (q.user.asId().toString() != myUser._id.toString())
			return HttpResponse.empty().setStatus(Forbidden);

		q.deleted = true;
		q.modified = Date.now();
		data.questions.update( { _id : id }, q);

		return HttpResponse.empty().redirect('/?msg=' + StringTools.urlEncode('Question successfully deleted'));
	}

	inline public static function toResult(q:db.Question, r:BaseRoute, extra:{ myUser:Null<ObjectId>, username:String, userpoint:Int, isFav:Bool, isFollowing:Bool }):QuestionResult
	{
		var q_user = q.user.get(r.data.users.col);
		return {
			data: {
				id : q._id,
				userID : q_user._id,
				userName : q_user.name,
				contents : q.contents,
				tags : q.tags,
				loc : q.loc,
				voteSum : q.voteSum,
				favorites : q.favorites,
				watchers : q.watchers,
				date : q.created,
				solved : q.solved,
				comments : [ for (c in q.comments) {
					userID : c.user.asId(),
					contents : c.contents,
					date : c.created,
					deleted : c.deleted
				} ],
				answers : [ for(a in q.answers) {
					userID : a.user.asId(),
					deleted : a.deleted,
					loc : a.loc,
					voteSum : a.voteSum,
					date : a.created,
					contents : a.contents,
					comments : [ for (c in a.comments) {
						userID : c.user.asId(),
						contents : c.contents,
						date : c.created,
						deleted : c.deleted
					} ]
				} ]
			},
			authenticated : r.loop.session.isAuthenticated(),
			myUser : extra.myUser,
			username : extra.username,
			userpoint : extra.userpoint,
			isFav : extra.isFav,
			isFollowing : extra.isFollowing
		};
	}

	public function postAnswer(id:ObjectId, args:{ answer:String }):HttpResponse<Dynamic>
	{
		var q = data.questions.findOne({ _id : id });
		if ( q == null )
			return HttpResponse.fromContent(
					new TemplateLink({ q:null }, function(_) return '<h1>Invalid question id $id</h1>'));

		q.answers.push({
			deleted: false,
			user: loop.session.user,
			contents: args.answer,
			loc: { lat: -23, lon: -43 },
			voteSum: 0,

			created: Date.now(),
			modified: Date.now(),

			comments: []
		});

		data.questions.update({ _id : id }, q);
		return HttpResponse.empty().redirect('/question/$id');
	}

	public function postComment(id:ObjectId, ?answerIndex : Int, args : { comment : String } ) : HttpResponse<Dynamic>
	{
		var q = data.questions.findOne( { _id : id } );
		if (q == null)
			return HttpResponse.fromContent(
					new TemplateLink( { q:null }, function(_) return '<h1>Invalid question id $id</h1>'));

		if (answerIndex == null)
		{
			q.comments.push( {
				user : loop.session.user,
				contents : args.comment,
				created : Date.now(),
				modified : Date.now(),
				deleted : false
			});

			data.questions.update( { _id : id }, q);
			return HttpResponse.empty().redirect('/question/$id');
		}
		else
		{
			var ans = q.answers[answerIndex];
			if (ans == null)
				return HttpResponse.fromContent(
						new TemplateLink( { q:null }, function(_) return '<h1>Invalid answer index $answerIndex</h1>'));

			ans.comments.push( {
				user : loop.session.user,
				contents : args.comment,
				created : Date.now(),
				modified : Date.now(),
				deleted : false
			});

			data.questions.update( { _id : id }, q);
			return HttpResponse.empty().redirect('/question/$id');
		}
	}
}

typedef QuestionResult = {
	data:{
		id : ObjectId,
		userID : ObjectId,
		userName : String,
		contents : String,
		tags : Array<String>,
		loc : db.helper.Location,
		voteSum : Int,
		favorites : Int,
		watchers : Int,
		date : Date,
		solved : Bool,
		comments : Array<{ userID : ObjectId, contents : String, date:Date, deleted : Bool }>,
		answers : Array<{
			userID : ObjectId,
			deleted : Bool,
			loc : Location,
			voteSum : Int,
			date : Date,
			contents : String,
			comments : Array<{userID : ObjectId, contents : String, date:Date, deleted : Bool}>
		}>
	},
	authenticated : Bool,
	myUser : Null<ObjectId>,
	username : String,
	userpoint : Int,
	isFav : Bool,
	isFollowing : Bool
};

@:includeTemplate("question.html")
class QuestionView extends erazor.macro.SimpleTemplate<QuestionResult>
{
}

