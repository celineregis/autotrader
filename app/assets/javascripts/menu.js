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

	setTimeout(askForUpdatesInLiveStatus, 0);

}