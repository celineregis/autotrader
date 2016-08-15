updateCheckBoxes = function(updates){
	updates.add.forEach(function(update){
		var selector = "#live-check-" + update
		$(selector).prop('checked', true)
	})

	updates.delete.forEach(function(update){
		var selector = "#live-check-" + update
		$(selector).prop('checked', false)
	})
}

function askForUpdatesInLiveStatus(){
	$.ajax({
    	type:'GET', 
    	url: '/updates',
    	dataType: "json", 
    	success: updateCheckBoxes
    });
    setTimeout(askForUpdatesInLiveStatus, 60000);
}




window.onload = function() {
	$(document).on('click', '.navie', function(event){
		event.preventDefault()
	    var targetSelector = ".table-" + event.target.parentElement.getAttribute('data-league')
	    $('.table-row').hide()
	    $(targetSelector).each(function(i, obj){
	    	$(obj).show();
	    })
	})

	$(document).on('input change', '.slide', function(event){
		$(event.target).animate({boxShadow : "0 0 5px 1px #c8102e"})
	});

	$(document).on('input change', '.form-control', function(event){
		$(event.target).animate({boxShadow : "0 0 5px 1px #c8102e"})
	});

	setGauges();

	

	setTimeout(askForUpdatesInLiveStatus, 0);


}

var setGauges = function(){
	var g = new JustGage({
	    id: "home-odd",
	    value: 1.8,
	    min: 1.7,
	    max: 2.0,
	    title: "Home"
  	});

  	var g = new JustGage({
	    id: "draw-odd",
	    value: 2.2,
	    min: 2.1,
	    max: 2.5,
	    title: "Draw"
  	});

  	var g = new JustGage({
	    id: "away-odd",
	    value: 3.4,
	    min: 3.2,
	    max: 3.6,
	    title: "Away"
  	});
}