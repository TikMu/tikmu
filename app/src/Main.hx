import view.*;
import croxit.*;

class Main
{
	static function main()
	{
		switch (Web.getURI())
		{
			case "/login":
				trace("login");
			case _:
				Output.println( new view.Main().execute() );
		}
	}
}
