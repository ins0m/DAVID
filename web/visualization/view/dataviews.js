/**
 * Created by ins0m on 26.01.14.
 */
/**
 * Created by ins0m on 26.01.14.
 */
$(document)
    .ready(function() {
        var dataViewsSortButtons = [
            $('#dataviews-sort-by-name'),
            $('#dataviews-sort-by-date'),
            $('#dataviews-sort-by-graphs'),
            $('#dataviews-sort-by-description')
        ];

        dataViewsSortButtons.forEach(function(targetButton){
            targetButton.click(function() {
                var criteriaHeader = $('.criteria');
                dataViewsSortButtons.forEach(function(elem){
                    elem.removeClass('active');
                });
                targetButton.addClass('active');
                criteriaHeader.removeClass();
                if (targetButton.hasClass('red')){
                    criteriaHeader.addClass('ui red header criteria block');
                } else if (targetButton.hasClass('blue')){
                    criteriaHeader.addClass('ui blue header criteria block');
                } else if (targetButton.hasClass('green')){
                    criteriaHeader.addClass('ui green header criteria block');
                } else if (targetButton.hasClass('teal')){
                    criteriaHeader.addClass('ui teal header criteria block');
                }
            });
        });
    });