$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("main").after(question);
            $("article.question.question_card").addClass ("blurred");
            $("div.question_open.modal, .div.question_open").fadeIn('slow');
        
        $(".overlay, .close").click(function() {
            $("div.question_open.modal, .div.question_open").fadeOut('slow');
            $("article.question.question_card, .div.question_open.modal").removeClass ("blurred overlay");    
        });
        });
        clk.preventDefault();
    });
});
