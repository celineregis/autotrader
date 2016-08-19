module UpdateLive

	LIVE_STATE = {
		1 => 0,
		2 => 45,
		3 => 45,
		4 => 105,
		5 => 105,
		6 => "ET Halftime",
		7 => 105,
		8 => "End of ET",
		9 => "Finished",
		10 => "Suspended",
		11 => "Penalties"
	}

	def get_ids_of_live_events
		live_events = get_live_fixtures_in_pinnacle_offering
		get_live_status_hash(live_events)
	end

	def get_live_odds_without_inwt_algorithm(pp_event_id)
		event = Event.find_by(pp_event_id: pp_event_id)
		if event
			league_id = []
			league_id << League.find(event.league_id).pp_league_id
			odds_hash = convert_to_format(get_odds(0, 0, "")[0])
			odds_hash[pp_event_id]
		end
	end

	def get_live_odds_by_id(pp_event_id)
		event = Event.find_by(pp_event_id: pp_event_id)
		if event
			league_id = []
			league_id << League.find(event.league_id).pp_league_id
			odds_hash = convert_to_asian_format(get_odds(0, 0, "")[0])
			event_odds = odds_hash[pp_event_id]
			get_live_hash_inwt(event_odds["hcp_line"], event_odds["home_odd"], event_odds["away_odd"], event_odds["points"], event_odds["over"], event_odds["under"])
		end
	end

	
	def get_live_status_hash(live_events)
		event_ids = []
		live_events.each do |league|
			league["events"].each do |event|
				event_ids << event["id"] if event["state"] < 7
			end
		end
		event_ids
	end

	def get_live_odds(token)
		get_odds(0, 1, token)
	end

	def get_over_prob(odds)
		total_prob = 1/odds["over"].to_f + 1/odds["under"].to_f
		over_equal_value_prob = 1/(odds["over"]*total_prob)
		over_equal_prob_prob = 1/odds["over"]-(total_prob-1)/2
		(100*(over_equal_value_prob+over_equal_prob_prob)/2).round
	end

	private

	def get_playing_minute(event)
		state = LIVE_STATE[event["state"]]
		state += event["elapsed"] unless LIVE_STATE[event["state"]].class == String
		state
	end

	def convert_to_format(live_odds)
		
		all_odds = {}
		live_odds.each do |league|
			league["events"].each do |event|
				event["periods"].each do |period|
				if period["number"] == 0 && period["moneyline"] 
						if period['totals']
							half_goal_lines = period['totals'].select{|points_line| points_line["points"]%0.5==0 && points_line["points"]%1!=0}
						else
							half_goal_lines = []
						end
						if half_goal_lines.length == 0
							lowest_goal_line = {
								"over" => 2.0,
								"under" => 2.0,
								"points" => 0
							}
						else
							lowest_goal_line = half_goal_lines.min_by{|line| line["points"]}
						end
						all_odds[event["id"]] = {
							"home_goals" => event["homeScore"],
							"away_goals" => event["awayScore"],
							"home_red" => event["homeRedCards"],
							"away_red" => event["awayRedCards"],
							"home_odd" => period["moneyline"]["home"],
							"draw_odd" => period["moneyline"]["draw"],
							"away_odd" => period["moneyline"]["away"],
							"goal_line" => lowest_goal_line["points"],
							"over" => lowest_goal_line["over"],
							"under" => lowest_goal_line["under"]
						}
					end
				end
			end
		end
		all_odds
	end

	def convert_to_asian_format(live_odds)
		all_odds = {}
		live_odds.each do |league|
			league["events"].each do |event|
				event["periods"].each do |period|
					if period["number"] == 0 && period["spreads"] && period["totals"]
						all_odds[event["id"]] = {
							"home_goals" => event["homeScore"],
							"away_goals" => event["awayScore"],
							"home_red" => event["homeRedCards"],
							"away_red" => event["awayRedCards"],
							"hcp_line" => period["spreads"][0]["hdp"],
							"home_odd" => period["spreads"][0]["home"],
							"away_odd" => period["spreads"][0]["away"],
							"goal_line" => period["totals"][0]["points"],
							"over" => period["totals"][0]["over"],
							"under" => period["totals"][0]["under"] 
						}
					end
				end
			end
		end
		all_odds
	end
	
	def update_live_record_for_events_with_live_status(live_events)
		event_ids = []
		live_events.each do |league|
			league["events"].each do |event|
				if event["state"] <= 3
					event_ids << event["id"]
				end
			end
		end
		event_ids
	end

	def update_goal_hash(old_goal_hash, new_goal_hash)
		goals_scored = old_goal_hash.select do |event_id, goals|
			goals != new_goal_hash[event_id.to_i]
		end
		if goals_scored.length == 0
			$redis.set("goals_scored", nil)
		else
			$redis.set("goals_scored", goals_scored.to_json)
		end
		$redis.set("live_goal_hash", new_goal_hash.to_json)
	end


end