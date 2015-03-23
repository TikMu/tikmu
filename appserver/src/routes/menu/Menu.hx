package routes.menu;

import mweb.tools.TemplateLink;
import routes.BaseRoute;

/**
 * ...
 * @author andy
 */

@:includeTemplate("menu.html")
class MenuView extends erazor.macro.SimpleTemplate<{ authenticated : Bool }> {
}
 
class Menu
{
	public static function doMenu(authenticated : Bool)
	{
		
		return new TemplateLink( { authenticated : authenticated }, new MenuView());
	}
}