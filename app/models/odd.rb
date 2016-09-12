class Odd < ApplicationRecord
	belongs_to :event
	@@last_update_for_event = {}
	
	def self.get_odds_for_event(event_id, first_time=false)
		event = Event.find(event_id)
		if event
			league_id = []
			league_id << League.find(event.league_id).pp_league_id
			if first_time
				result = get_odds(league_id, 0, "")
				odds_hash = convert_to_asian_format(result[0])
		    else
		    	result = get_odds(league_id, 0, get_token("event_odd_token"))
		    	odds_hash = result[0] ? convert_to_asian_format(result[0]) : {}
		    end
			token = result[1]
			store_token(token, "event_odd_token")
			event_odds = odds_hash[event.pp_event_id]
			if event_odds 
				event_odds["home_goals"] = 0 if event_odds["home_goals"].nil?
				event_odds["away_goals"] = 0 if event_odds["away_goals"].nil?
				if event.is_live
					event_odds["playing_minute"] = $playing_minutes[event.pp_event_id]
				else
					event_odds["playing_minute"] = 0
				end
				event_info = {
					home_goals: event_odds["home_goals"],
					away_goals: event_odds["away_goals"],
					playing_minute: event_odds["playing_minute"] 
				}
				@@last_update_for_event = [get_live_hash_inwt(
					event_odds["hcp_line"], event_odds["home_odd"], 
					event_odds["away_odd"], event_odds["goal_line"], 
					event_odds["over"], event_odds["under"], event_odds["home_goals"], 
					event_odds["away_goals"], event_odds["playing_minute"] 
				), event_info]
			end
			@@last_update_for_event
		end
	end
end