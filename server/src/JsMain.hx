import js.JQuery;

class JsMain
{

	static function main()
	{
		croxit.js.Client.onDeviceReady(function() {
			new JQuery('.add-comment a').click(function(ev) {
				ev.preventDefault();
				JQuery.cur.siblings('.comentar').show();
				JQuery.cur.hide();
			});

			new JQuery('.row.single .icon-reply').click(function(ev) {
				ev.preventDefault();
				new JQuery('.resposta textarea').focus();
			});
		});

	}
}
