@:includeTemplate("route/aux/menu.html")
class MenuView extends BaseView<{}> {}

class AuxiliaryContext {
	public var menu(default,null):MenuView;

	public function new(ctx)
	{
		menu = new MenuView(ctx);
	}
}

