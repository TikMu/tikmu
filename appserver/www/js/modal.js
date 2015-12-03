$(document).ready(function(){
    $(".question_card_question > a, .question_card_answers > a").click(function(clk){
        $.get(this.href).done(function(html){
            var data = $(html).filter("div.question_open");
            var question = $("<div class='question_open modal'></div>");
            data.appendTo(question);
            $("main").after(question);

            var windowOffset = $(document).scrollTop();
            var questionHeight = $('.question_open_inner').height();
            var windowHeight = $(window).height();
            var positionModal;

            // positioning the modal relative to scrolled window

            if (questionHeight <= windowHeight - 60) {
                positionModal = windowOffset + ((windowHeight - 60 - questionHeight) / 2);
            }
            else {
                positionModal = windowOffset + 120;
            }

            $('.question_open_inner').css({'top':positionModal});
            $(".grid").css({'max-height':questionHeight + 430 , 'overflow':'hidden'});
            $("article.question.question_card").addClass("blurred");


        $(".overlay, .close").click(function() {
            $("div.question_open.modal, .div.question_open, .overlay").fadeOut(4000);; 
            $("article.question.question_card").removeClass ("blurred");
            $("div.question_open.modal, .div.question_open, .overlay").detach();   
        });
        });
        clk.preventDefault();
    });
});

