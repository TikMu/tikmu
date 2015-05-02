package route;

import mweb.tools.*;

typedef UserViewData = {
	user : {
		name:String,
		?email:String
	}
}

@:template("Viewing user @user.name (@user.email)")
class UserView extends BaseView<UserViewData> {}

class User extends BaseRoute {
	var view:UserView;

	@openRoute
	public function anyDefault(?email:String)
	{
		var user = null;
		if (email != null)
			user = data.users.findOne({ email : email });
		else if (loop.session.isAuthenticated())
			user = loop.session.user.get(data.users.col);

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
	public function anyId(id:ObjectId)
	{
		var user = data.users.col.findOne({ _id : id });

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
		view = new UserView(_ctx);
	}
}

