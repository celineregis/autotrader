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
	$('#Standard-0').text(oddsHash.home_odd)
	$('#Standard-1').text(oddsHash.draw_odd)
	$('#Standard-2').text(oddsHash.away_odd)
	$('#OverUnderBullshit').text(oddsHash.over_odd)
	$('#OverUnder25-0').text(oddsHash.over_odd)
	$('#OverUnder25-1').text(oddsHash.under_odd)
	if($("#score").data('live')){
		$("#score").text(oddsHash.home_goals + "-" +  oddsHash.away_goals);
		setTimeout(getUpdatedOdds, 10000);
	}else{
		setTimeout(getUpdatedOdds, 40000);
	}
	//Todo over under
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

