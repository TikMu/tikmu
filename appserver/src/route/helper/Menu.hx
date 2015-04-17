package route.helper;

import mweb.tools.*;

@:includeTemplate("menuView.html")
class MenuView extends erazor.macro.SimpleTemplate<{}> {
	var ctx:Context;

	public function new(ctx)
	{
		this.ctx = ctx;
		super();
	}
}

class Menu extends routes.BaseRoute {
	var view:MenuView;

	@openRoute
	public function any()
	{
		return HttpResponse.fromContent(new TemplateLink(null, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new MenuView(ctx);
	}
}

