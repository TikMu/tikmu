(function (console, $hx_exports) { "use strict";
$hx_exports.js = $hx_exports.js || {};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
var MainJS = function() { };
MainJS.__name__ = true;
MainJS.main = function() {
	croxit_js_Client.onDeviceReady(function() {
		haxe_Log.trace = function(msg,infos) {
			var pstr;
			if(infos == null) pstr = "(null)"; else pstr = infos.fileName + ":" + infos.lineNumber;
			var str = pstr + ": " + Std.string(msg);
			if(infos != null && infos.customParams != null) {
				var _g = 0;
				var _g1 = infos.customParams;
				while(_g < _g1.length) {
					var v = _g1[_g];
					++_g;
					str += "," + Std.string(v);
				}
			}
			console.log(str);
		};
		js_Lib.window.onerror = function(errorMsg,url,lineNumber) {
			haxe_Log.trace("[ERROR] (" + url + ":" + lineNumber + ") " + errorMsg,{ fileName : "MainJS.hx", lineNumber : 22, className : "MainJS", methodName : "main"});
		};
	});
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.__name__ = true;
haxe_Timer.delay = function(f,time_ms) {
	var t = new haxe_Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
};
haxe_Timer.prototype = {
	stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
};
var croxit_js_Client = function() { };
croxit_js_Client.__name__ = true;
croxit_js_Client.send = function(protocol,msg,cback) {
	throw "Error: Trying to send content before device is ready";
};
croxit_js_Client.onDeviceReady = function(fn) {
	croxit_js_Client.deviceReady.push(fn);
};
var haxe_Log = function() { };
haxe_Log.__name__ = true;
haxe_Log.trace = function(v,infos) {
	js_Boot.__trace(v,infos);
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
};
js_Boot.__trace = function(v,i) {
	var msg;
	if(i != null) msg = i.fileName + ":" + i.lineNumber + ": "; else msg = "";
	msg += js_Boot.__string_rec(v,"");
	if(i != null && i.customParams != null) {
		var _g = 0;
		var _g1 = i.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			msg += "," + js_Boot.__string_rec(v1,"");
		}
	}
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js_Boot.__unhtml(msg) + "<br/>"; else if(typeof console != "undefined" && console.log != null) console.log(msg);
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
var js_Functions = $hx_exports.js.Functions = function() { };
js_Functions.__name__ = true;
js_Functions.run = function() {
	croxit_js_Client.onDeviceReady(function() {
	});
};
js_Functions.confirmDeleteQuestion = function(questionID) {
	if(questionID != "" && window.confirm("Tem certeza que deseja deletar essa questão?")) window.location.href = "/deletequestion/" + questionID;
};
js_Functions.confirmDeleteAnswer = function(questionID,answerIndex) {
	if(questionID != "" && answerIndex > 0 && window.confirm("Tem certeza que deseja deletar essa resposta?")) window.location.href = "/deleteanswer/" + questionID + "/" + answerIndex;
};
js_Functions.confirmDeleteComment = function(questionID,answerIndex,commentIndex) {
	if(questionID != "" && (answerIndex == null || answerIndex > 0) && commentIndex > 0 && window.confirm("Tem certeza que deseja deletar essa resposta?")) window.location.href = "/deletecomment/" + questionID + "/" + answerIndex + "/" + commentIndex;
};
js_Functions.markQuestionAsSolved = function(questionID) {
	if(questionID != "") window.location.href = "/markquestionassolved/" + questionID;
};
js_Functions.voteUp = function(questionID,answerIndex) {
	if(questionID != "" && (answerIndex == null || answerIndex > 0)) window.location.href = "/voteup/" + questionID + (answerIndex != null?"/" + answerIndex:"");
};
js_Functions.voteDown = function(questionID,answerIndex) {
	if(questionID != "" && (answerIndex == null || answerIndex > 0)) window.location.href = "/votedown/" + questionID + (answerIndex != null?"/" + answerIndex:"");
};
js_Functions.toggleFav = function(questionID) {
	if(questionID != "") window.location.href = "/togglefavorite/" + questionID;
};
js_Functions.toggleFollow = function(questionID) {
	if(questionID != "") window.location.href = "/togglefollow/" + questionID;
};
var js_Lib = function() { };
js_Lib.__name__ = true;
var js_Menu = $hx_exports.js.Menu = function() { };
js_Menu.__name__ = true;
js_Menu.run = function() {
	croxit_js_Client.onDeviceReady(function() {
		js.JQuery("#searchString").bind("keyup",function(ev) {
			if(!js.JQuery("#istag")["is"](":checked")) return;
			if(ev.keyCode == 32) {
				var tag = js.JQuery(this).val();
				if(StringTools.trim(tag) == "") return;
				js.JQuery(this).val("");
				js.JQuery("#tagContainer").append("<span class=\"tag\" id=\"tag" + js_Menu.tagID + "\">" + tag + "&nbsp;<a onclick=\"js.Menu.removeTag(tag+" + js_Menu.tagID + ");\"></a></span>");
				js_Menu.tagID++;
			}
		});
		js.JQuery("#submitsearch").bind("click",function(_) {
			var isTagSearch = js.JQuery("#istag")["is"](":checked");
			if(isTagSearch) {
				var tags = [];
				var tagContainer = js.JQuery("#tagContainer");
				var $it0 = (function($this) {
					var $r;
					var _this = tagContainer.children(".tag");
					$r = (_this.iterator)();
					return $r;
				}(this));
				while( $it0.hasNext() ) {
					var t = $it0.next();
					if(StringTools.trim(t.text()) != "") tags.push(t);
				}
				if(tags.length > 0) {
				}
			} else {
				var query = js.JQuery("#searchString").val();
				if(StringTools.trim(query) == "") return; else {
				}
			}
		});
	});
};
js_Menu.removeTag = function(id) {
	js.JQuery("#" + id).parent().empty();
};
String.__name__ = true;
Array.__name__ = true;
var __deviceReadyCalled = false;
var $window = window;
var document = window.document;
$window.onload = function(_) {
	haxe_Timer.delay(function() {
		if(!__deviceReadyCalled) {
			__deviceReadyCalled = true;
			
					var evt = document.createEvent('Event');
					evt.initEvent('deviceready', true, true);
					document.dispatchEvent(evt);
			while(croxit_js_Client.deviceReady.length > 0) (croxit_js_Client.deviceReady.pop())();
		}
	},500);
};
if(document.addEventListener) document.addEventListener("deviceready",function() {
	if(__deviceReadyCalled) haxe_Log.trace("Device ready was already called!",{ fileName : "Client.hx", lineNumber : 36, className : "croxit.js.Client", methodName : "__init__"});
	__deviceReadyCalled = true;
	while(croxit_js_Client.deviceReady.length > 0) (croxit_js_Client.deviceReady.pop())();
},false);
var q = window.jQuery;
var js = js || {}
js.JQuery = q;
q.fn.iterator = function() {
	return { pos : 0, j : this, hasNext : function() {
		return this.pos < this.j.length;
	}, next : function() {
		return $(this.j[this.pos++]);
	}};
};
croxit_js_Client.deviceReady = [];
js_Menu.tagID = 0;
MainJS.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports);
