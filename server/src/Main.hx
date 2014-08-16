import db.*;
import view.*;
import croxit.*;
import haxe.web.*;

class Main
{
	public static function main()
	{
		haxe.Log.trace = function(msg:Dynamic, ?pos:haxe.PosInfos) {
			msg = pos.customParams == null ? msg : msg + "," + pos.customParams.join(',');
			Web.logMessage('${pos.fileName}:${pos.lineNumber} $msg');
		};
		db.InitDb.init();
		run();
		sys.db.Manager.cnx.close();
	}

	public static function run()
	{
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
					Web.redirect('/login?msg=voce precisa estar logado');
			}
		}
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
