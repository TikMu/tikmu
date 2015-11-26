$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("article.question.question_open").fadeTo("slow", 1);
            $("main").after(question);
            $("article.question.question_card").addClass("blurred");

        $(".overlay, .close").click(function() {
            $("div.question_open.modal, .div.question_open").fadeTo("slow", 0);;
            $("article.question.question_card").removeClass ("blurred");
            $("div.question_open.modal, .div.question_open, .overlay").detach();   
        });
        });
        clk.preventDefault();
    });
});