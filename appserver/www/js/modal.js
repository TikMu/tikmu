$(document).ready(function(){
	$(".question_card_question > a, .question_card_answers > a").click(function(){
    	console.log(this.href);
    	$.get(this.href).done(function(x){
    		console.log(x);
    	});
  	});
});


