$(document).ready(function(){
	$(".question_card_question > a, .question_card_answers > a").click(function(clk){
    	$.get(this.href).done(function(html){
    		var data = $(html).filter("main.question_open");
    		var question = $("<div class='question_open modal'></div>");
    		data.appendTo(question);
    		$("main").after(question);
    	});
    	clk.preventDefault();

    	$(".question_open.modal").click(function() {
            $(".question_open.modal, question_open").hide('fast', function() {
            });
        });
  	});
});
