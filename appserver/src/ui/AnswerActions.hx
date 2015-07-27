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
		var aid = elem.parents("article.answer").attr("id");
		var spans = elem.siblings().add(elem);
		var upvote = spans.filter(".upvote");
		var downvote = spans.filter(".downvote");
		var count = spans.filter(".vote_count");

		if (elem.hasClass("pressed"))
			action = action != QDoUpvote ? QDoUpvote : QDoDownvote;

		var inc = action == QDoUpvote ? 1 : -1;

		function style(state : { vote : Int }) {
			switch (state.vote) {
			case  1: upvote.addClass("pressed"); downvote.removeClass("pressed");
			case  0: upvote.removeClass("pressed"); downvote.removeClass("pressed");
			case -1: upvote.removeClass("pressed"); downvote.addClass("pressed");
			}

			count.html(Std.string(Std.parseInt(count.html()) + inc));
		}
		function onFail() {
			elem.toggleClass("pressed");
			count.html(Std.string(Std.parseInt(count.html()) - inc));
		}

		elem.toggleClass("pressed");
		JQuery.post('/answer/$aid/$action', style, "text json").fail(onFail);
		e.preventDefault();
	}

	public static var upvote = answerAction.bind(QDoUpvote);
	public static var downvote = answerAction.bind(QDoDownvote);
}

