class Event < ApplicationRecord
	has_many :selections
	belongs_to :league
	validates :pp_event_id, presence: true, uniqueness: true
	validates_format_of :home, without: /Corner/
	validates_format_of :home, without: /Corners/

	def self.update_events(seed_mode = false)
		event_token = get_token("event_token")
		#events_with_odds = get_events_with_odds
		if seed_mode
			result_array = get_fixtures(0, 0, "") 
		else
			result_array = get_fixtures(0, 0, event_token) 
		end
		unless result_array[0].nil?
			events_list = result_array[0]
			events_list.each do |league|
				l = League.find_by pp_league_id: league["id"]
				if l 
					league["events"].each do |event|
					# 	if events_with_odds.select{|event_with_odds| event_with_odds == event["id"]}.length>0 
						 	e = l.events.create(
						 		pp_event_id: event["id"],
						 		event_start: event["starts"],
						 		home: event["home"],
						 		away: event["away"],
						 	)
						 	
					# 	end
					end
				end
			end
		end
		store_token(result_array[1],"event_token")
	end

	def self.update_live_status
		updates = self.check_for_changes_in_live_status
		Event.update_active_record_live_status(updates)
		updates
	end

	private 

	def self.get_events_with_odds
		events_with_odds = []
		odds = get_odds(0, 0, "")[0]
		odds.each do |league|
			league["events"].each do |event|
				event["periods"].each do |period|
					if period["number"] == 0 && period["spreads"] && period["totals"]
						events_with_odds << event["id"]
					end
				end
			end
		end
		events_with_odds
	end

	def self.check_for_changes_in_live_status
		results = self.get_live_ids
		current_ids = results
		update_live_events = {
			add: current_ids - $live_events,
			delete: $live_events - current_ids,
		}
		$live_events = current_ids
		update_live_events
	end

	def self.get_live_ids
		live_events = get_live_fixtures_in_pinnacle_offering
		get_live_status_hash(live_events)
	end

	def self.update_active_record_live_status(updates)
		
		updates[:add].each do |event_id|
			event = Event.find_by(pp_event_id: event_id)
			if event
				event.is_live = true
				event.save
			end
		end
		updates[:delete].each do |event_id|
			event = Event.find_by(pp_event_id: event_id)
			if event
				event.is_live = false
				event.save
			end
		end
	end

	

end