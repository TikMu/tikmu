package dispatch;
import croxit.*;

class Ask
{
	public static function run()
	{
		Output.print( new view.Ask().setData( {} ).execute() );
	}
}


