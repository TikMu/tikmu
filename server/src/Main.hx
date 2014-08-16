import view.*;
import croxit.*;

class Main
{
	public static function main()
	{
		db.InitDb.init();
		run();
		sys.db.Manager.cnx.close();
	}

	public static function run()
	{
		haxe.web.Dispatch.run(Web.getURI(), Web.getParams(), {
			doDefault: dispatch.QuestionList.run,
			doLogin: dispatch.Login.run,
			doQuestion: dispatch.Question.run,
			doAsk:dispatch.Ask.run
		});
	}
}
