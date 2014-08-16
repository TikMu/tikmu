package dispatch;
import croxit.*;

class Login
{
	public static function run(?args:{ email:String, pass:String })
	{
		if (args != null)
		{
			var user = db.User.manager.select($email == args.email);
			if (user == null || !user.checkPass(args.pass))
			{
				Output.print( new view.Login().setData({ msg: "Erro de login" }).execute() );
			} else {
				var s = new db.Session();
				s.user = user;
				s.insert();
				s.set();

				Web.redirect('/');
			}
		} else {
			Output.print( new view.Login().setData({ msg: Web.getParams().get('msg') }).execute() );
		}
	}
}
