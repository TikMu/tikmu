$(document).ready(function(){
	$(".question_card_question > a, .question_card_answers > a").click(function(clk){
    	$.get(this.href).done(function(html){
    		var data = $(html).$("main.question_open");
    		var question = $("<div class='question_open modal'></div>");
    		data.appendTo(question);
    		$("main").after(question);
    	});
    	clk.preventDefault();
  	});
});
