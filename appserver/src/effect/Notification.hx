package effect;

import effect.Event;

class Notification {
	var ctx:Context;
	var data(get,never):StorageContext;
		inline function get_data() return ctx.data;
	var loop(get,never):IterationContext;
		inline function get_loop() return ctx.loop;

	public function dispatch(event:Event)
	{
		switch (event) {
		case EvAnsPost(ans,qst):
			if (qst.user == loop.session.user)
				return;
			trace("notify: question owner of posted answer");
			data.userNotifications.update(
				{ _id : qst.user },
				{ "$push" : { msg : "New answer" } },
				true
			);
		case EvCmtPost(cmt,ans,qst):
			trace("notify: TODO notify question owner of posted answer");
			trace("notify: notify answer owner of posted comment");
		case _:
		}
	}

	public function new(context:Context)
	{
		ctx = context;
	}
}

