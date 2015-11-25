$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("main").after(question);
                $(".overlay, .close").click(function() {
                $(".question_open.modal, div.question_open").fadeOut('slow');
        });
        });
        clk.preventDefault();
    });
});