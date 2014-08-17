package tools;

class Naming
{
	public static function formatDate(date:Date)
	{
		date = Date.fromString(date.toString());
		var cur = Date.now().getTime(),
				dt = date.getTime();
		var delta = cur - dt;
		return if (delta < 60 * 1000)
		{
			'alguns instantes atrás';
		} else if (delta < 60 * 60 * 1000) {
			var min = Std.int(delta / (60 * 1000));
			min + ' minutos atrás';
		} else if (delta < 24 * 60 * 60 * 1000) {
			var hours = Std.int(delta / (60 * 60 * 1000));
			hours + ' horas atrás';
		} else if (delta < 30 * 24 * 60 * 60 * 1000) {
			var days = Std.int(delta / (24 * 60 * 60 * 1000));
			days + ' dias atrás';
		} else {
			date.toString(); //fix me
		}
	}
}
