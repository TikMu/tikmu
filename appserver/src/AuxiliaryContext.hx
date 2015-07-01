typedef HeadViewData = {
	title : String
}

@:includeTemplate("route/aux/head.html")
class HeadView extends BaseView<HeadViewData> {
	public function new(ctx)
	{
		super(ctx);
		data = { title : null };
	}
}

@:includeTemplate("route/aux/menu.html")
class MenuView extends BaseView<{}> {}

class AuxiliaryContext {
	public var head(default,null):HeadView;
	public var menu(default,null):MenuView;

	public function new(ctx)
	{
		head = new HeadView(ctx);
		menu = new MenuView(ctx);
	}
}

