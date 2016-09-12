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
	
	Object.keys(oddsHash[0]).forEach(function(market_name){
		Object.keys(oddsHash[0][market_name]).forEach(function(param){
			for(var i=0; i<oddsHash[0][market_name][param]["odds"].length; i++){
				selector = "#" + market_name.replace(/[\. ,:-]+/g, "") + param.toString().replace('.','').replace(':','') + i
				$(selector).text(Math.round(100*oddsHash[0][market_name][param]["odds"][i])/100)	
			}
		})
	})
	
	if($("#score").data('live')){
		$("#score").text(oddsHash[1].home_goals + "-" +  oddsHash[1].away_goals);
		var widthString = parseInt(oddsHash[1].playing_minute/0.9) + "%"
		$("#pb-playing-minute").css( "width", widthString)
		$("#pb-playing-minute").text(oddsHash[1].playing_minute)
		setTimeout(getUpdatedOdds, 20000);
	}else{
		setTimeout(getUpdatedOdds, 40000);
	}
	
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
		console.log("asking for hash")
		$.ajax({ 
		    type:'GET', 
		    url: request_url,
		    dataType: "json", 
		    success: updateLiveOdds
	    });
	}else{
		setTimeout(getUpdatedOdds, 10000);
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
	setTimeout(pollingForUpdates, 10);
	
});

