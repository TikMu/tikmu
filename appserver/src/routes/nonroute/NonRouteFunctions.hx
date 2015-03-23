package routes.nonroute;
import mweb.tools.HttpResponse;
import mweb.tools.TemplateLink;
import routes.BaseRoute;
import routes.question.QuestionRoute.QuestionView;

/**
 * ...
 * @author andy
 */
class DeleteQuestion extends BaseRoute
{
	public function any(id : String)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null)
		{
			q.deleted = true;
			q.modified = Date.now();
			ctx.questions.update( { _id : id }, q);
			//TODO: ver se eles querem que propague o deleted
		}
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}
	
class EditQuestion extends BaseRoute
{
	public function any(id : String)
	{
		return HttpResponse.empty().redirect('/');	
	}
}

class DeleteAnswer extends BaseRoute
{
	public function any(questionId : String, index : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : questionId } );
		var errorCode = -1; //Question não encontrada
		if (q != null || !(index > 0))
		{
			if (q.answers != null && q.answers.length > 0)
			{
				errorCode = 0; //Até aqui tudo ok!
				var ans = q.answers[index];
				if (ans != null)
				{
					ans.deleted = true;
					ans.modified = Date.now();
					ctx.questions.update( { _id : questionId }, q);
					//TODO: ver se eles querem que propague o deleted
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
	public function any(questionId : String, index : Int)
	{
		return HttpResponse.empty().redirect('/');
	}
}

class DeleteComment extends BaseRoute
{
	public function any(questionId : String, answerIndex : Int, commentIndex : Int)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : questionId } );
		var errorCode = -1; //Question não encontrada
		if (q != null || !(answerIndex > 0) || !(commentIndex > 0))
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
						if (comment != null)
						{
							comment.deleted = true;
							comment.modified = Date.now();
							ctx.questions.update( { _id : questionId }, q);
						}
						else 
							errorCode = -5; //Comentário não encontrado
					}
					else
						errorCode = -4; //Sem comentários (LOL)
				}
				else errorCode = -3; //Answer não encontrada
			}
			else errorCode = -2; //Sem respostas
		}
		return HttpResponse.fromContent(new TemplateLink({ data: { id : q._id, userID : q.user.get(ctx.users.col)._id, userName : q.user.get(ctx.users.col).name, contents : q.contents, tags : q.tags, loc : q.loc, voteSum : q.voteSum, favorites : q.favorites, watchers : q.watchers, date : q.created, solved : q.solved, answers : [for(a in q.answers) { userID : a.user.get(ctx.users.col)._id, deleted : a.deleted, loc : a.loc, voteSum : a.voteSum, date : a.created, contents : a.contents, comments : [for(c in a.comments){userID : c.user.get(ctx.users.col)._id, contents : c.contents, date:c.created, deleted : c.deleted}] } ] }, authenticated : (ctx.session != null), myUser : myUser }, new QuestionView()));
	}
}

class EditComment extends BaseRoute
{
	public function any(questionId : String, answerIndex : Int, commentIndex : Int)
	{
		return HttpResponse.empty().redirect('/');
	}
}

class MarkQuestionAsSolved extends BaseRoute
{
	//Deixei como Toggle, mas nunca se sabe.
	public function any(id : String)
	{
		var myUser = ctx.session.user.get(ctx.users.col)._id;
		var q = ctx.questions.findOne( { _id : id } );
		var errorCode = -1; //Question não encontrada
		if (q != null)
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
	public function any(questionId : String)
	{
		return HttpResponse.empty().redirect('/');
	}
}

class ToggleFollow extends BaseRoute
{
	public function any(questionId : String)
	{
		return HttpResponse.empty().redirect('/');
	}
}