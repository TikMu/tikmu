package routes.nonroute;

import db.UserQuestions;
import db.helper.Ref.Ref;
import mweb.http.*;
import mweb.tools.TemplateLink;
import routes.ObjectId;
import routes.question.QuestionRoute.QuestionView;

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

