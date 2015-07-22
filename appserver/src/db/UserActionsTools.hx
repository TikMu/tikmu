package db;

import db.helper.Ref;

class UserActionsTools {
	public static function getUserActions(uid:Ref<User>, data:StorageContext, ?create=false)
	{
		var ret = data.userActions.findOne({ _id : uid });
		if (!create)
			return ret;

		if (ret == null)
			ret = {
				_id : uid,
				onQuestion : [],
				onAnswer : []
			}
		return ret;
	}

	public static function questionSummary(actions:UserActions, qid:Ref<Question>)
	{
		var sum = null;
		if (actions != null)
			sum = Lambda.find(actions.onQuestion, function (x) return x.question.equals(qid));
		return if (sum != null) {
			favorite : sum.favorite,
			following : sum.following
		} else {
			favorite : false,
			following : false
		}
	}
}

