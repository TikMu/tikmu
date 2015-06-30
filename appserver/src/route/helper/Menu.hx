package route.helper;

import mweb.tools.*;

@:includeTemplate("menu.html")
class MenuView extends BaseView<{}> {}

class Menu extends BaseRoute {
	var view:MenuView;

	@openRoute @login
	public function any()
	{
		return HttpResponse.fromContent(new TemplateLink(null, view));
	}

	public function new(ctx)
	{
		super(ctx);
		view = new MenuView(_ctx);
	}
}

