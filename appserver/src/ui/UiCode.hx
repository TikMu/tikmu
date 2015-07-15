package ui;

import js.Browser.*;
import js.html.*;

class UiCode {
	static function register(nodeList:NodeList, func:Event->Bool)
	{
		for (i in 0...nodeList.length) {
			var anchor = cast(nodeList[i], AnchorElement);
			anchor.onclick = func;
		}
	}

	static function main()
	{
		window.onload = function () {
			var favBtns = document.querySelectorAll(".favorite.icon");
			var flwBtns = document.querySelectorAll(".follow.icon");
			register(favBtns, QuestionActions.favorite);
			register(flwBtns, QuestionActions.follow);
		}
	}
}

