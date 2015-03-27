package js;
import croxit.js.Client;

using StringTools;

@:expose @:keep
class Menu
{
	static var tagID = 0;
	public static function run(){
		Client.onDeviceReady(function() {
			new JQuery('#searchString').bind('keyup', function(ev) {
				if (!new JQuery('#istag').is(':checked'))
					return;
				if (ev.keyCode == 32)//space
				{
					var tag = JQuery.cur.val();
					if (tag.trim() == '')
						return;
					JQuery.cur.val('');
					new JQuery('#tagContainer').append('<span class="tag" id="tag' + tagID + '">' + tag + '&nbsp;<a onclick="js.Menu.removeTag(tag+' + tagID + ');"></a></span>');
					tagID++;
				}
			});
			
			new JQuery('#submitsearch').bind('click', function(_) {
				var isTagSearch = new JQuery('#istag').is(':checked');
				if (isTagSearch)
				{
					var tags = [];
					var tagContainer = new JQuery('#tagContainer');
					for (t in tagContainer.children('.tag'))
					{
						if (t.text().trim() != '')
							tags.push(t);
					}
					if (tags.length > 0)
					{
						//Send Parameters and Call Search
					}
				}
				else
				{
					var query = new JQuery('#searchString').val();
					if (query.trim() == '')
						return;
					else
					{
						//Send Parameters and Call Search
					}
				}
			});
		});
	}
	
	public static function removeTag(id : String)
	{
		new JQuery('#' + id).parent().empty();
	}
}