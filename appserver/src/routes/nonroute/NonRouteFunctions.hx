package routes.nonroute;

import db.UserQuestions;
import db.helper.Ref.Ref;
import mweb.http.*;
import mweb.tools.TemplateLink;
import routes.ObjectId;
import routes.question.QuestionRoute.QuestionView;

//MASS TODO: Handle In-place array updates

class MarkQuestionAsSolved extends BaseRoute
{
	public function any(id:ObjectId)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null && q.user == ctx.session.user)
		{
			q.solved = !q.solved;
			q.modified = Date.now();
			ctx.questions.update( { _id : id }, q);
		}
		return Response.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class VoteUp extends BaseRoute
{
	public function any(id:ObjectId, ?answerIndex : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var questionUser = ctx.userQuestions.findOne( { _id:myUser } );

		if (questionUser == null)
		{
			var uq = {
				_id : myUser,
				data : [{ question : q._id,
						votes : [{answer : answerIndex, up : true}],
						favorite : false,
						following : false,
				}]
			};
			ctx.userQuestions.insert(uq);

			if (answerIndex == null)
			{
				q.voteSum++;
				ctx.questions.update({ _id : q._id }, q);

				var user = q.user.get(ctx.users.col);
				user.points++;
				ctx.users.update({ _id : user._id }, user);
			}
			else
			{
				q.answers[answerIndex].voteSum++;
				ctx.questions.update({ _id : q._id }, q);

				var user = q.answers[answerIndex].user.get(ctx.users.col);
				user.points++;
				ctx.users.update({ _id : user._id }, user);
			}
		}
		else
		{
			var exists = false;
			for (d in questionUser.data)
			{
				if (d.question == q)
				{
					exists = true;
					var alreadyVoted = false;
					for (v in d.votes)
					{
						if (v.answer == answerIndex)
						{
							alreadyVoted = true;
							if (!v.up)
							{
								v.up = true;
								if (answerIndex == null)
								{
									q.voteSum += 2; //Minus downvote and Plus upvote
									ctx.questions.update({ _id : q._id }, q);

									var user = q.user.get(ctx.users.col);
									user.points+= 2;
									ctx.users.update({ _id : user._id }, user);
								}
								else
								{
									q.answers[answerIndex].voteSum += 2; //Same
									ctx.questions.update({ _id : q._id }, q);

									var user = q.answers[answerIndex].user.get(ctx.users.col);
									user.points+= 2;
									ctx.users.update({ _id : user._id }, user);
								}
							}
							break;
						}
					}
					if (!alreadyVoted)
					{
						d.votes.push( { answer : answerIndex, up : true } );
						if (answerIndex == null)
						{
							q.voteSum++;
							ctx.questions.update({ _id : q._id }, q);

							var user = q.user.get(ctx.users.col);
							user.points++;
							ctx.users.update({ _id : user._id }, user);
						}
						else
						{
							q.answers[answerIndex].voteSum++;
							ctx.questions.update({ _id : q._id }, q);

							var user = q.answers[answerIndex].user.get(ctx.users.col);
							user.points++;
							ctx.users.update({ _id : user._id }, user);
						}
					}
					break;
				}
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
			}
			if (!exists)
			{
				questionUser.data.push({ question : q,
										votes : [{answer : answerIndex, up : true}],
										favorite : false,
										following : false,
										});
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);

				if (answerIndex == null)
				{
					q.voteSum++;
					ctx.questions.update({ _id : q._id }, q);
				}
				else
				{
					q.answers[answerIndex].voteSum++;
					ctx.questions.update({ _id : q._id }, q);
				}
			}
		}

		return Response.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class VoteDown extends BaseRoute
{
	public function any(id:ObjectId, ?answerIndex : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var questionUser = ctx.userQuestions.findOne( { _id:myUser } );

		if (questionUser == null)
		{
			var uq = {
				_id : myUser,
				data : [{ question : q._id,
						votes : [{answer : answerIndex, up : false}],
						favorite : false,
						following : false,
				}]
			};
			ctx.userQuestions.insert(uq);

			if (answerIndex == null)
			{
				q.voteSum--;
				ctx.questions.update({ _id : q._id }, q);

				var user = q.user.get(ctx.users.col);
				user.points--;
				ctx.users.update({ _id : user._id }, user);
			}
			else
			{
				q.answers[answerIndex].voteSum--;
				ctx.questions.update({ _id : q._id }, q);

				var user = q.answers[answerIndex].user.get(ctx.users.col);
				user.points--;
				ctx.users.update({ _id : user._id }, user);
			}
		}
		else
		{
			var exists = false;
			for (d in questionUser.data)
			{
				if (d.question == q)
				{
					exists = true;
					var alreadyVoted = false;
					for (v in d.votes)
					{
						if (v.answer == answerIndex)
						{
							alreadyVoted = true;
							if (v.up)
							{
								v.up = false;
								if (answerIndex == null)
								{
									q.voteSum -= 2; //Minus upvote and Plus downvote
									ctx.questions.update({ _id : q._id }, q);

									var user = q.user.get(ctx.users.col);
									user.points-= 2;
									ctx.users.update({ _id : user._id }, user);
								}
								else
								{
									q.answers[answerIndex].voteSum -= 2; //Same
									ctx.questions.update({ _id : q._id }, q);

									var user = q.user.get(ctx.users.col);
									user.points-= 2;
									ctx.users.update({ _id : user._id }, user);
								}
							}
							break;
						}
					}
					if (!alreadyVoted)
					{
						d.votes.push( { answer : answerIndex, up : false } );
						if (answerIndex == null)
						{
							q.voteSum--;
							ctx.questions.update({ _id : q._id }, q);

							var user = q.user.get(ctx.users.col);
							user.points--;
							ctx.users.update({ _id : user._id }, user);
						}
						else
						{
							q.answers[answerIndex].voteSum--;
							ctx.questions.update({ _id : q._id }, q);

							var user = q.user.get(ctx.users.col);
							user.points-= 2;
							ctx.users.update({ _id : user._id }, user);
						}
					}
					break;
				}
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
			}
			if (!exists)
			{
				questionUser.data.push({ question : q,
										votes : [{answer : answerIndex, up : false}],
										favorite : false,
										following : false,
										});
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);

				if (answerIndex == null)
				{
					q.voteSum--;
					ctx.questions.update({ _id : q._id }, q);
				}
				else
				{
					q.answers[answerIndex].voteSum--;
					ctx.questions.update({ _id : q._id }, q);
				}
			}
		}

		return Response.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

