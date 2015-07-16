package ui;

import js.jquery.Helper.*;
import js.jquery.*;

@:enum abstract QuestionAction(String) from String {
	var QDoFavorite = "favorite";
	var QDoFollow = "follow";
}

class QuestionActions {
	static function questionAction(action:QuestionAction, e:Event)
	{
		var elem = J(e.target);
		var qid = elem.attr("question-id");
		var r = JQuery.post('/question/$qid/$action');
		r.done(elem.toggleClass.bind("icon_pressed"));
		e.preventDefault();
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

