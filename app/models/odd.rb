class Odd < ApplicationRecord
	belongs_to :selection
	has_many :bets
	@@last_update_for_event = {}
	
	def self.get_odds_for_event(event_id, first_time=false)
		puts "recieving the request"
		t = Time.now
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
			time_for_request = Time.now - t 
			puts "recieved the odds from pinnacle #{time_for_request}"
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
				time_for_request = Time.now - t 
				puts "recieved the odds from INWT #{time_for_request}"
			end
			self.write_odds_to_database(@@last_update_for_event, event_id)
			@@last_update_for_event
		end
	end

	def self.write_odds_to_database(odds_hash, event_id)
		market_name_convertion_hash = self.get_market_name_conversion_hash
		odds_hash[0].each do |market_name_inwt, paramater_hash|
			market_name = market_name_convertion_hash[market_name_inwt]
			paramater_hash.each do |paramater, odds_hash|
				if self.paramater_allowed?(paramater)
					odds_hash[:odds].each.with_index(1) do |odd, index|
						selection = Selection.where({event_id: event_id ,market_name: market_name, paramater: paramater, choice_paramater: index})
						selection_odd = Odd.find_by(selection_id: selection[0].id)
						unless selection_odd && selection_odd.reference_odd == odd
							selection[0].odds.create(
								reference_odd: odd
							)	
						end
					end
				end
			end
		end
	end

	private

	def self.paramater_allowed?(paramater)
		["0:1","0:2","1:0","2:0","0.5","1.5","2.5",""].include? paramater
	end

	def self.get_market_name_conversion_hash
		{
			"standard" => "Match Winner",
			"double-chance" => "Double Chance",
			"handicap-rest" => "Handicap Remaining Time",
			"next-point" => "Next Goal",
			"points-more-less-rest" => "Over Under Remaining Time",
			"standard-rest" => "Remaining Time"
		}
	end



			
	
end