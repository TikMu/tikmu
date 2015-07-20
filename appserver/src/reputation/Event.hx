package reputation;

import db.Question;
import db.User;

enum EventValue {
	RPostQuestion;
	// RViewQuestion;
	RFavoriteQuestion;    // TODO use
	RUnfavoriteQuestion;  // TODO use
	RFollowQuestion;      // TODO use
	RUnfollowQuestion;    // TODO use
	// RUpvoteQuestion(amount:Float);
	// RDownvoteQuestion(amount:Float);

	// TODO answers

	// TODO comments

	// TODO users (??)
}

enum EventTarget {
	RQuestion(q:Question);
	// RAnswer(a:Answer, q:Question);
	// RComment(c:Comment, a:Answer, q:Question);
	ROwner(u:User);  // the user that owner the target of the event
}

typedef Event = {
	value : EventValue,
	target : EventTarget
}

