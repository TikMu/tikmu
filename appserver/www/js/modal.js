$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("main").after(question);


            $('div.question_open.modal, .div.question_open, .overlay').fadeIn('slow'); 
            $('article.question.question_card').addClass('is-blurred');
            $('body').addClass('is-locked');

        $(".overlay, .close").click(function() {
            $('div.question_open.modal, .div.question_open, .overlay').fadeOut('slow', function() { 
                $(this).remove(); 
                $('article.question.question_card').removeClass('is-blurred');
                $('body').removeClass('is-locked');
            });
            });
        });
        clk.preventDefault();
    });
});

