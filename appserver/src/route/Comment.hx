package route;

import db.Question;
import mweb.tools.*;
import route.Question;

class SomeComment extends BaseRoute {
	var question:db.Question;
	var answer:db.Answer;
	var comment:db.Comment;

	@openRoute
	public function any()
	{
		return new HttpResponse().redirect('/question/${question._id.valueOf()}#${comment._id.valueOf()}');
	}

	public function postEdit(args:{ updated:String })
	{
		if (!comment.user.equals(loop.session.user))
			return new HttpResponse().setStatus(Unauthorized);

		comment.contents = args.updated;
		comment.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new HttpResponse().redirect('/question/${question._id.valueOf()}#${comment._id.valueOf()}');
	}

	public function postDelete()
	{
		if (!comment.user.equals(loop.session.user))
			return new HttpResponse().setStatus(Unauthorized);

		comment.deleted = true;
		comment.modified = loop.now;
		data.questions.update({ _id : question._id }, question);
		return new HttpResponse().redirect('/question/${question._id.valueOf()}#${answer._id.valueOf()}');
	}

	public function new(ctx, question, answer, comment)
	{
		super(ctx);
		this.question = question;
		this.answer = answer;
		this.comment = comment;
	}
}

class Comment extends BaseRoute {
	@openRoute
	public function anyDefault(d:mweb.Dispatcher<HttpResponse<Dynamic>>, id:ObjectId):HttpResponse<Dynamic>
	{
		var question = data.questions.findOne({
			answers : {"$elemMatch":{
				comments : {"$elemMathc":{
					_id : id,
					deleted : false
				}},
				deleted : false
			}},
			deleted : false
		});
		if (question == null)
			return new HttpResponse().setStatus(NotFound);  // TODO handle mweb behavior
		
		for (answer in question.answers) {
			for (comment in answer.comments) {
				if (comment._id.equals(id))
					return d.dispatch(new SomeComment(_ctx, question, answer, comment));
			}
		}
		return null;  // should never reach this
	}
}


