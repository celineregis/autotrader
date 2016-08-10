USER = "RV548242"
PASSWORD = "123!!!AAA"
$live_events = Odd.get_live_ids
$live_events.each do |event_id|
	event = Event.find_by(pp_event_id: event_id)
	if event
		event.is_live = true 
		event.save
	end
end