window.onload = function() {

	$(document).on('click', '.navie', function(event){
		event.preventDefault()
	    var targetSelector = ".table-" + event.target.parentElement.getAttribute('data-league')
	    $('.table-row').hide()
	    $(targetSelector).each(function(i, obj){
	    	$(obj).show();
	    })
	})   
	    
}