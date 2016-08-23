require 'rserve/simpler'
USER = "RV548242"
PASSWORD = "123!!!AAA"
$R = Rserve::Simpler.new
$R.command "source('C:/Users/verbeekr/Dev/autotrader/lib/external_scripts/wrapper_inwt.R')"
$playing_minutes = {}
Event.update_events
$live_events = Event.get_live_ids
$live_events.each do |event_id|
	event = Event.find_by(pp_event_id: event_id)
	if event
		event.is_live = true 
		event.save
	end
end