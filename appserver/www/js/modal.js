$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("main").after(question);

            // var windowOffset = $(document).scrollTop();
            // var questionHeight = $('.question_open_inner').height();
            // var windowHeight = $(window).height();
            // var positionModal;

            // positioning the modal relative to scrolled window

            // if (questionHeight <= windowHeight - 60) {
            //     positionModal = windowOffset + ((windowHeight - 60 - questionHeight) / 2);
            // }
            // else {
            //     positionModal = windowOffset + 120;
            // }
            $('div.question_open.modal, .div.question_open, .overlay').fadeIn(800); 
            $('.question_open_inner').css({'top':200});
            $('body').css({'overflow':'hidden'});
            $('div.question_open.modal').css({'display':'block'});
            $('article.question.question_card').addClass('blurred');

        $(".overlay, .close").click(function() {
            $('div.question_open.modal, .div.question_open, .overlay').fadeOut(600, function() { 
        $(this).remove(); 

            $("article.question.question_card").removeClass ('blurred');
            $('body').css({'overflow':'auto'});
            });
            });
        });
        clk.preventDefault();
    });
});

