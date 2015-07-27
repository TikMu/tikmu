package tikmu;

import db.Question;
import db.User;

enum EventValue {
	RPostQuestion;

	// RViewQuestion;  // TODO
	RFavoriteQuestion;
	RUnfavoriteQuestion;
	RFollowQuestion;
	RUnfollowQuestion;
	RPostAnswer;

	RUpvoteAnswer;
	RDownvoteAnswer;
	RPostComment;
}

enum EventTarget {
	RQuestion(q:Question);
	RAnswer(a:Answer, q:Question);
	RComment(c:Comment, a:Answer, q:Question);
}

typedef Event = {
	value : EventValue,
	target : EventTarget
}

