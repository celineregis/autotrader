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

updateLiveOdds = function(oddsHash){
	debugger
}

function askForUpdatesInLiveStatus(){
	if(window.location.href==="http://localhost:3000/"){
		$.ajax({
	    	type:'GET', 
	    	url: '/updates',
	    	dataType: "json", 
	    	success: updateCheckBoxes
    	});
	}
	setTimeout(askForUpdatesInLiveStatus, 60000);
}

function pollingForUpdates(){
	askForUpdatesInLiveStatus();
	getUpdatedOdds();
}

function getUpdatedOdds(){
	var currentPageArray = window.location.href.split('/')
	var request_url = currentPageArray[currentPageArray.length-1] + '/updates'
	if(window.location.href != "http://localhost:3000/"){
		$.ajax({ 
		    type:'GET', 
		    url: request_url,
		    dataType: "json", 
		    success: updateLiveOdds
	    });
	}
	setTimeout(getUpdatedOdds, 1000);
}

$(document).ready(function(){
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
	setTimeout(pollingForUpdates, 0);
	
});

