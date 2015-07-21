@:abstractTemplate
class BaseView<T> extends erazor.macro.SimpleTemplate<T> {
	var ctx:Context;

	public function new(ctx)
	{
		super();
		this.ctx = ctx;
	}

	function getUser(id)
	{
		var u = ctx.data.users.col.findOne({ _id : id });
		if (u == null)
			return null;
		return {
			email : u.email,
			name : u.name,
			points : u.points
		}
	}

	function getPrettyDelta(date:Date)
	{
		var delta = ctx.loop.now.getTime() - date.getTime();
		var keys = ["m", "h", "d", "w"];

		var d = Std.int(1e-3*delta/60);
		var i = 1;
		for (div in [60, 24, 7]) {
			var _d = Std.int(d/div);
			if (_d == 0)
				break;
			d = _d;
			i++;
		}
		return '${d}${keys[i-1]}';
	}
}

