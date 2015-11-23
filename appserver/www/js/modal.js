$(document).ready(function(){
	$(".question_card_question > a, .question_card_answers > a").click(function(clk){
    	$.get(this.href).done(function(html){
    		var data = $(html).filter("div.question_open");
    		var question = $("<div class='question_open modal'></div>");
    		data.appendTo(question);
    		$("div.question_open").after(question);
                $(".overlay").click(function() {
                $(".question_open.modal, div.question_open").hide('fast', function() {
            });
        });
    	});
    	clk.preventDefault();
  	});
});
