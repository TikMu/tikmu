package route;

import mweb.tools.*;

typedef ListViewData = {
	questions : Array<db.Question>,
	title : String,
}

@:includeTemplate("list.html")
class ListView extends erazor.macro.SimpleTemplate<ListViewData>
{
	public var ctx:Context;

	public function new(ctx)
	{
		this.ctx = ctx;
		super();
	}
}

class List extends BaseRoute
{
	var view:ListView;

	@openRoute
	public function any()
	{
		var data = { 
			questions : ctx.questions.find({}).toArray(),
			title : "Discover"
		};
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

class Favorites extends BaseRoute
{
	var view:ListView;

	public function any()
	{
		var uq = ctx.userQuestions.findOne({ _id : ctx.session.user });
		var qds = uq != null ? uq.data : [];

		var qs = [ for (qd in qds) if (qd.favorite) qd.question.get(ctx.questions.col) ];

		var data = {
			questions : qs,
			title : "Favorites"
		};
		return HttpResponse.fromContent(new TemplateLink(data, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

class Search extends BaseRoute
{
	var view:ListView;

	@openRoute
	public function any(?args:{query:Array<String>, ?useTags:Bool})
	{
		return HttpResponse.empty().redirect("/");
	}

	public function new(ctx)
	{
		super(ctx);
		view = new ListView(ctx);
	}
}

