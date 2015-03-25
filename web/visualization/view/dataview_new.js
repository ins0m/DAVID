/**
 * Created by waldmann on 30.01.14.
 */
$(document)
    .ready(function() {
        var repositoryButtons= $('.repository');

        var subMenuActvator = function(i,targetButton){
            $(targetButton).click(function() {
                $('.datacall').each(function(i,elem){
                    $(elem).removeClass('active');
                });

                $('.visualization-toggle').click(function(){
					$(this).toggleClass('active');
                    $('.ui.accordion')
                        .accordion()
                    ;
                });
                $(targetButton).addClass('active');
            });
        };

        var activator = function(i,targetButton){
            $(targetButton).click(function() {
                $('.datacall').each(subMenuActvator);
                repositoryButtons.each(function(i,elem){
                    $(elem).removeClass('active');
                });
                $(targetButton).addClass('active');
            });
        };
        repositoryButtons.each(activator);




    });