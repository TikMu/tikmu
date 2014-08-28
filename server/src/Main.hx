import db.*;
import view.*;
import croxit.*;
import haxe.web.*;

class Main
{
	static var init = false;
	public static function main()
	{
		if (!init)
		{
			init = true;
			haxe.Log.trace = function(msg:Dynamic, ?pos:haxe.PosInfos) {
				msg = pos.customParams == null ? msg : msg + "," + pos.customParams.join(',');
				Web.logMessage('${pos.fileName}:${pos.lineNumber} $msg');
			};
#if cpp
			croxit.Croxit.setBounces(false);
			trace('aqui');
			Geo.init(2);
#end
		}
		sys.db.Manager.initialize();
		run();
	}

	public static function run()
	{
		db.InitDb.init();
		sys.db.Manager.cleanup();
		var d = new Dispatch(Web.getURI(),Web.getParams());
		d.onMeta = function(m,value) {
			switch (m)
			{
				case 'logged':
					var sess = Session.get();
					if (sess == null)
						throw NotLogged;
			}
		}

		try
		{
			d.dispatch(new Main());
		}
		catch(e:Error)
		{
			switch(e)
			{
				case NotLogged:
					Web.redirect('/login?msg=' + StringTools.urlEncode("Você precisa estar logado"));
			}
		}
		tools.History.request();
		sys.db.Manager.cnx.close();
	}

	var doDefault = dispatch.QuestionList.run;
	var doLogin = dispatch.Login.run;
	var doQuestion = dispatch.Question.run;
	@logged var doAsk = dispatch.Ask.run;
	var doCreate = dispatch.CreateUser.run;
	@logged var doAnswer = dispatch.Answer.run;
	@logged var doVote = dispatch.Vote.run;
	@logged var doComment = dispatch.Comment.run;

	private function new()
	{
	}
}

enum Error {
	NotLogged;
}
