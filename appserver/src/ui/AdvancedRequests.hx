package ui;

import js.Browser.*;
import js.html.*;

class AdvancedRequests {
	static function toggleIconPressed(elem:Element)
	{
		if (elem.classList.contains("icon_pressed"))
			elem.classList.remove("icon_pressed");
		else
			elem.classList.add("icon_pressed");
	}

	static function questionAction(action:String, e:Event)
	{
		var elem = cast(e.target, Element);
		var qid = elem.getAttribute("question-id");
		trace(qid);
		var r = new XMLHttpRequest();
		r.onloadend = function (e) {
			trace(r.status);
			switch (r.status) {
			case 204:  // no content
				toggleIconPressed(elem);
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
		return questionAction("favorite", e);
	}

	static function follow(e:Event)
	{
		return questionAction("follow", e);
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

