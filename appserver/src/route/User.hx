package route;

import mweb.tools.*;

typedef UserViewData = {
	user : {
		name:String,
		?email:String
	}
}

@:template("Viewing user @user.name (@user.email)")
class UserView extends erazor.macro.SimpleTemplate<UserViewData> {
	var ctx:Context;

	public function new(ctx)
	{
		this.ctx = ctx;
		super();
	}
}

class User extends routes.BaseRoute {
	var view:UserView;

	@openRoute
	public function anyDefault(?email:String)
	{
		var user = null;
		if (email != null)
			user = ctx.users.findOne({ email : email });
		else if (ctx.session.isAuthenticated())
			user = ctx.session.user.get(ctx.users.col);

		var ret = new HttpResponse();

		if (user == null) {
			ret.setStatus(NotFound);
			return ret;
		}

		var data = {
			user : {
				email : user.email,
				name : user.name
			}
		}

		ret.setContent(new TemplateLink(data, view));
		return ret;
	}

	@openRoute
	public function anyId(id:routes.ObjectId)
	{
		var user = ctx.users.col.findOne({ _id : id });

		var ret = new HttpResponse();

		if (user == null) {
			ret.setStatus(NotFound);
			return ret;
		}

		var data = {
			user : {
				email : user.email,
				name : user.name
			}
		}

		ret.setContent(new TemplateLink(data, view));
		return ret;
	}

	public function new(ctx)
	{
		super(ctx);
		view = new UserView(ctx);
	}
}

