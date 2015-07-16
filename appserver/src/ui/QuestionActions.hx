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
		function setIcons(state:{ favorite:Bool, following:Bool }) {
			var icons = elem.siblings().add(elem);
			var favorite = icons.filter(".favorite");
			var follow = icons.filter(".follow");
			if (state.favorite != favorite.hasClass("icon_pressed"))
				favorite.toggleClass("icon_pressed");
			if (state.following != follow.hasClass("icon_pressed"))
				follow.toggleClass("icon_pressed");
		}
		JQuery.post('/question/$qid/$action', setIcons, "text json");
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

