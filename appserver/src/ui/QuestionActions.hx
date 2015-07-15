package ui;

import js.html.*;

@:enum abstract QuestionAction(String) from String {
	var QDoFavorite = "favorite";
	var QDoFollow = "follow";
}

class QuestionActions {
	static function questionAction(action:QuestionAction, e:Event)
	{
		var elem = cast(e.target, Element);
		var qid = elem.getAttribute("question-id");
		var r = new XMLHttpRequest();
		r.onloadend = function (e) {
			trace(r.status);
			switch (r.status) {
			// TODO 200
			case 200, 204:  // no content
				if (elem.classList.contains("icon_pressed"))
					elem.classList.remove("icon_pressed");
				else
					elem.classList.add("icon_pressed");
			case s:
				throw 'Unexpected status $s';
			}
		}
		r.open("POST", '/question/$qid/$action');
		r.send();
		return false;
	}

	public static function favorite(e:Event)
	{
		return questionAction(QDoFavorite, e);
	}

	public static function follow(e:Event)
	{
		return questionAction(QDoFollow, e);
	}
}

