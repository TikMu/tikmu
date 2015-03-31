package routes.nonroute;

import db.UserQuestions;
import db.helper.Ref.Ref;
import mweb.tools.HttpResponse;
import mweb.tools.TemplateLink;
import routes.BaseRoute;
import routes.ObjectId;
import routes.question.QuestionRoute.QuestionView;

//MASS TODO: Handle In-place array updates
class DeleteQuestion extends BaseRoute
{
	public function any(id:ObjectId)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null && q.user == ctx.session.user)
		{
			q.deleted = true;
			q.modified = Date.now();
			ctx.questions.update( { _id : id }, q);			
		}
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}
	
class EditQuestion extends BaseRoute
{
	public function any(id:ObjectId)
	{
		//TODO:
		return HttpResponse.empty().redirect('/');	
	}
}

class DeleteAnswer extends BaseRoute
{
	public function any(id:ObjectId, index : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null || !(index > 0))
		{
			if (q.answers != null && q.answers.length > 0)
			{
				errorCode = 0; //Até aqui tudo ok!
				var ans = q.answers[index];
				if (ans != null && ans.user == ctx.session.user)
				{
					ans.deleted = true;
					ans.modified = Date.now();
					ctx.questions.update( { _id : id }, q);					
				}
				else errorCode = -3; //Answer não encontrada
			}
			else errorCode = -2; //Sem respostas
		}
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class EditAnswer extends BaseRoute
{
	public function any(id:ObjectId, index : Int)
	{
		//TODO:
		return HttpResponse.empty().redirect('/');
	}
}

class DeleteComment extends BaseRoute
{
	public function any(id:ObjectId, ?answerIndex : Int, commentIndex : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null || !(commentIndex > 0))
		{
			if (answerIndex == null)
			{
				errorCode = 0;//Até aqui tudo ok!
				var comment = q.comments[commentIndex];
				if (comment != null && comment.user == ctx.session.user)
				{
					comment.deleted = true;
					comment.modified = Date.now();
					ctx.questions.update( { _id : id }, q);
				}
				else
					errorCode = -6; //Comentário para Pergunta não encontrado
			}
			else if (answerIndex > 0)
			{
				if (q.answers != null && q.answers.length > 0)
				{
					errorCode = 0; //Até aqui tudo ok!
					var ans = q.answers[answerIndex];
					if (ans != null)
					{
						if (ans.comments != null && ans.comments.length > 0)
						{
							var comment = ans.comments[commentIndex];
							if (comment != null && comment.user == ctx.session.user)
							{
								comment.deleted = true;
								comment.modified = Date.now();
								ctx.questions.update( { _id : id }, q);
							}
							else 
								errorCode = -5; //Comentário para resposta não encontrado
						}
						else
							errorCode = -4; //Sem comentários (LOL)
					}
					else errorCode = -3; //Answer não encontrada
				}
				else errorCode = -2; //Sem respostas
			}
		}
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class EditComment extends BaseRoute
{
	public function any(id:ObjectId, ?answerIndex : Int, commentIndex : Int)
	{
		//TODO:
		return HttpResponse.empty().redirect('/');
	}
}

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
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class ToggleFavorite extends BaseRoute
{
	public function any(id:ObjectId)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
				
		var questionUser = ctx.userQuestions.findOne({ _id:myUser});
		trace(questionUser);
		
		if (questionUser == null)
		{
			var uq = {
				_id : myUser,
				data : [{ question : q._id,
						votes : new Array<{answer : Null<Int>, up : Bool}>(),
						favorite : true,
						following : false,
				}]
			};
			ctx.userQuestions.insert(uq);
		}
		else
		{
			var exists = false;
			for (d in questionUser.data)
			{
				if (d.question == q)
				{
					//if Toggle favorite off, must toggle follow off
					if (d.favorite && d.following)
						d.following = false;					
					d.favorite = !d.favorite;
					exists = true;
					ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
					break;
				}				
			}
			if (!exists)
			{
				questionUser.data.push({ question : q,
										votes : new Array<{answer : Null<Int>, up : Bool}>(),
										favorite : true,
										following : false,
										});
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
			}
		}
		
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class ToggleFollow extends BaseRoute
{
	public function any(id:ObjectId)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
				
		var questionUser = ctx.userQuestions.findOne({ _id:myUser});
		trace(questionUser);
		
		if (questionUser == null)
		{
			var uq = {
				_id : myUser,
				data : [{ question : q._id,
						votes : new Array<{answer : Null<Int>, up : Bool}>(),
						favorite : true, //+follow implies +fav
						following : true,
				}]
			};
			ctx.userQuestions.insert(uq);
		}
		else
		{
			var exists = false;
			for (d in questionUser.data)
			{
				if (d.question == q)
				{				
					d.following = !d.following;
					exists = true;
					ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
					break;
				}				
			}
			if (!exists)
			{
				questionUser.data.push({ question : q,
										votes : new Array<{answer : Null<Int>, up : Bool}>(),
										favorite : true, //+follow implies  +fav
										following : true,
										});
				ctx.userQuestions.update({ _id : questionUser._id }, questionUser);
			}
		}
		
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
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
		
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
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
		
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}
