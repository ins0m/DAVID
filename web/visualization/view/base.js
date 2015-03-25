/**
 * Created by ins0m on 26.01.14.
 */
$(document)
	.ready(function() {

		var theBigBar = $('#master-sidebar-big');
		var theSmallBar =$('#master-sidebar-small');
		theBigBar.sidebar().sidebar('show');
		theSmallBar.sidebar();

		$('#master-sidebar-expand').click(function() {
			if (theBigBar.sidebar('is open')){
				theSmallBar.sidebar('show');
				$('#master-sidebar-expand-icon').removeClass().addClass("right arrow icon");
			} else {
				theBigBar.sidebar('show');
				$('#master-sidebar-expand-icon').removeClass().addClass("left arrow icon");
			}

		});

        $('#background-blue-abstract').click(function() {
            $('body').css('background','url("../res/img/blue-abstract.jpg")');
            $('body').css('background-size','100% 100%');
        });

        $('#background-wood').click(function() {
            $('body').css('background','url("../res/img/wood.jpg")');
            $('body').css('background-size','100% 100%');
        });


		$('#background-grid').click(function() {
			$('body').css('background','url("../res/img/grid.jpg")');
			$('body').css('background-size','initial');
		});

		$('#background-black-c').click(function() {
			$('body').css('background','black');
			$('body').css('background-size','100% 100%');
		});

		$('#background-white').click(function() {
			$('body').css('background','white');
			$('body').css('background-size','100% 100%');
		});


		$('.ui.dropdown')
			.dropdown()
		;
	});