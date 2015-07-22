package ui;

import js.jquery.Helper.*;

class UiCode {
	static function main()
	{
		// note: 'ready' doesn't wait for assets
		JTHIS.ready(function () {
			J(".favorite.icon").click(QuestionActions.favorite);
			J(".follow.icon").click(QuestionActions.follow);
			J(".upvote").click(AnswerActions.upvote);
			J(".downvote").click(AnswerActions.downvote);
		});
	}
}

