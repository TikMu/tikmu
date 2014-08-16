package dispatch;
import croxit.*;

class CreateUser
{
	public static function run(?args:{ nome:String, email:String, pass:String } )
	{
		if (args != null)
		{
			var user = db.User.manager.select($email == args.email);
			if (user == null)
			{
				user = new db.User();
				user.email = args.email;
				user.name = args.nome;
				user.rate = 2;
				user.setPass(args.pass);
				user.insert();
				var s = new db.Session();
				s.user = user;
				s.insert();
				s.set();

				Web.redirect('/');
			} else {
				Web.redirect('/create?msg=este usuário já existe');
			}
		} else {
			croxit.Output.print( new view.CreateUser().setData({ msg:Web.getParams().get('msg') }).execute() );
		}
	}
}
