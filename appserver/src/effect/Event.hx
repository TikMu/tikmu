package effect;

import db.Question;
import db.User;

enum Event {
	EvQstPost(q:Question);
	// EvQstView(q:Question);
	EvQstFavorite(q:Question);
	EvQstUnfavorite(q:Question);
	EvQstFollow(q:Question);
	EvQstUnfollow(q:Question);

	EvAnsPost(a:Answer, q:Question);
	EvAnsUpvote(a:Answer, q:Question);
	EvAnsDownvote(a:Answer, q:Question);

	EvCmtPost(c:Comment, a:Answer, q:Question);
}

