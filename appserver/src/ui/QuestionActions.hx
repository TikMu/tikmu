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
		var qid = elem.parents("article.question").attr("id");
		var icons = elem.siblings().add(elem);
		var favorite = icons.filter(".favorite");
		var follow = icons.filter(".follow");

		function getState() {
			return {
				favorite : favorite.hasClass("pressed"),
				following : follow.hasClass("pressed")
			}
		}
		function applyState(state:{ favorite:Bool, following:Bool }) {
			if (state.favorite != favorite.hasClass("pressed"))
				favorite.toggleClass("pressed");
			if (state.following != follow.hasClass("pressed"))
				follow.toggleClass("pressed");
		}

		var curState = getState();
		if (elem.is(favorite))
			applyState({
				favorite : !curState.favorite,
				following : curState.following && !curState.favorite
			});
		else
			applyState({
				favorite : curState.favorite || !curState.following,
				following : !curState.following
			});
		JQuery.post('/question/$qid/$action', applyState, "text json").fail(applyState.bind(curState));
		e.preventDefault();
	}

	public static var favorite = questionAction.bind(QDoFavorite);
	public static var follow = questionAction.bind(QDoFollow);
}

