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
#if cpp
			var latest = croxit.geo.Location.getLatest();
			if (latest != null)
			{
				loc.lat = latest.latitude;
				loc.lon = latest.longitude;
			} else {
				loc.lat = -23.666;
				loc.lon = -48.666;
			}
#else
			loc.lat = -23;
			loc.lon = -48;
#end
			loc.prettyName = "São Paulo (" + loc.lat + "," + loc.lon + ")";
			loc.insert();
			quest.location = loc;
			quest.insert();
			Web.redirect('/');
			// quest.
		}
	}
}


