package dispatch;
import croxit.*;

class Ask
{
	public static function run(?args: { askdata:String, nsfw:Bool })
	{
		if (args == null)
		{
			Output.print( new view.Ask().setData( {} ).execute() );
		} else {
			var quest = new db.Question();
			quest.contents = args.askdata;
			quest.isNsfw = args.nsfw ? true : false;
			quest.date = Date.now();
			quest.user = db.Session.get().user;
			var loc = new db.Location();
			loc.lat = -23;
			loc.lon = -48;
			loc.prettyName = "São Paulo - Augusta Street";
			loc.insert();
			quest.location = loc;
			quest.insert();
			Web.redirect('/');
			// quest.
		}
	}
}


