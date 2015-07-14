package ui;

import js.Browser.*;
import js.html.*;

@:enum abstract QuestionAction(String) from String {
	var QDoFavorite = "favorite";
	var QDoFollow = "follow";
}

class AdvancedRequests {
	static function questionAction(action:QuestionAction, e:Event)
	{
		var elem = cast(e.target, Element);
		var qid = elem.getAttribute("question-id");
		var r = new XMLHttpRequest();
		r.onloadend = function (e) {
			trace(r.status);
			switch (r.status) {
			// TODO 200
			case 200, 204:  // no content
				if (elem.classList.contains("icon_pressed"))
					elem.classList.remove("icon_pressed");
				else
					elem.classList.add("icon_pressed");
			case s:
				throw 'Unexpected status $s';
			}
		}
		r.open("POST", '/question/$qid/$action');
		r.send();
		return false;
	}

	static function favorite(e:Event)
	{
		return questionAction(QDoFavorite, e);
	}

	static function follow(e:Event)
	{
		return questionAction(QDoFollow, e);
	}

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
			var favBtns = document.querySelectorAll("a#favorite");
			var flwBtns = document.querySelectorAll("a#follow");
			register(favBtns, favorite);
			register(flwBtns, follow);
		}
	}
}

