package ui;

import js.jquery.Helper.*;
import js.jquery.*;

@:enum abstract AnswerAction(String) from String {
	var QDoUpvote = "upvote";
	var QDoDownvote = "downvote";
}

class AnswerActions {
	static function answerAction(action:AnswerAction, e:Event)
	{
		var elem = J(e.target);
		if (elem.hasClass("pressed"))
			action = action != QDoUpvote ? QDoUpvote : QDoDownvote;

		var aid = elem.parents("article.answer").attr("id");
		function style(state : { vote : Int }) {
			var spans = elem.siblings().add(elem);
			var upvote = spans.filter(".upvote");
			var downvote = spans.filter(".downvote");
			switch (state.vote) {
			case  1: upvote.addClass("pressed"); downvote.removeClass("pressed");
			case  0: upvote.removeClass("pressed"); downvote.removeClass("pressed");
			case -1: upvote.removeClass("pressed"); downvote.addClass("pressed");
			}

			var count = spans.filter(".vote_count");
			var val = Std.parseInt(count.html());
			switch (action) {
			case QDoUpvote: count.html(Std.string(val + 1));
			case QDoDownvote: count.html(Std.string(val - 1));
			}
		}
		JQuery.post('/answer/$aid/$action', style, "text json");
		e.preventDefault();
	}

	public static var upvote = answerAction.bind(QDoUpvote);
	public static var downvote = answerAction.bind(QDoDownvote);
}

