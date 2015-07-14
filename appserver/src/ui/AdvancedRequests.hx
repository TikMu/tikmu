package ui;

import js.Browser.*;
import js.html.*;

class AdvancedRequests {
	static function favorite(e:Event)
	{
		var anchor = cast(e.target, AnchorElement);
		var qid = anchor.getAttribute("question-id");
		trace(qid);
		var r = new XMLHttpRequest();
		r.open("POST", '/question/$qid/favorite');
		r.send();
		trace(r.status);
		return false;
	}

	static function follow(e:Event)
	{
		var anchor = cast(e.target, AnchorElement);
		var qid = anchor.getAttribute("question-id");
		trace(qid);
		var r = new XMLHttpRequest();
		r.open("POST", '/question/$qid/follow');
		r.send();
		trace(r.status);
		return false;
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

