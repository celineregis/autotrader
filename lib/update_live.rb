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

	def get_live_events_hash
		live_events_hash = {} 
		new_goal_hash = {}
		live_events = get_live_fixtures_in_pinnacle_offering
		update_live_record_for_events_with_live_status(live_events)
		unless live_events.length == 0
			result = get_live_odds("")
			$redis.set("live_odds_token", result[1])
			all_odds = convert_to_format(result[0])
			unless all_odds.length == 0
				all_events = JSON.parse($redis.get("in_play_events"))
				all_leagues = JSON.parse($redis.get("leagues"))
				begin
					old_goal_hash = JSON.parse($redis.get("live_goal_hash")) 
				rescue
					old_goal_hash = {}
				end
				live_events.each do |league|
					league["events"].each do |event|
						league_info = all_leagues[league["id"].to_s]
						event_info = all_events[event["id"].to_s]
						odds_info = all_odds[event["id"]]
						if league_info && event_info && odds_info
							live_events_hash[league_info["group"]] ||= {}
							live_events_hash[league_info["group"]][league_info["name"]] ||= {}
							current_goals = odds_info["home_goals"]+ odds_info["away_goals"]
							next_goal_text = get_next_goal_text(odds_info, current_goals)
							next_goal_prob = get_over_prob(odds_info)
							playing_minute = get_playing_minute(event)
							probs = convert_odds_to_probabilities(odds_info)
							live_stats = get_live_stats(event["id"])
							new_goal_hash[event["id"]] = odds_info["home_goals"] + odds_info["away_goals"]
							live_events_hash[league_info["group"]][league_info["name"]][event["id"]]={
								home_team: event_info["home"],
								away_team: event_info["away"],
								minute: playing_minute,
								state: event["state"],
								home_goals: odds_info["home_goals"],
								away_goals: odds_info["away_goals"],
								home_red: odds_info["home_red"],
								away_red: odds_info["away_red"],
								home_prob: probs[0],
								draw_prob: probs[1],
								away_prob: probs[2],
								next_goal_prob: next_goal_prob,
								next_goal_text: next_goal_text,
								live_stats: live_stats
							}
						end
					end
				end
				update_goal_hash(old_goal_hash, new_goal_hash)
			end
		end
		#live_events_hash = seed_live_hash
		$redis.set "live_events_hash", live_events_hash.to_json
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
						half_goal_lines = period['totals'].select{|points_line| points_line["points"]%0.5==0 && points_line["points"]%1!=0}
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

	def convert_odds_to_probabilities(odds)
		total_prob = 1/odds["home_odd"]+1/odds["draw_odd"]+1/odds["away_odd"]
		home_equal_value_prob = 1/(odds["home_odd"]*total_prob)
		draw_equal_value_prob = 1/(odds["draw_odd"]*total_prob)
		home_equal_prob_prob =  1/odds["home_odd"]-(total_prob-1)/3
		draw_equal_prob_prob =  1/odds["draw_odd"]-(total_prob-1)/3
		home_weighted_average = 0.4 * home_equal_value_prob + 0.6 * home_equal_prob_prob
		draw_weighted_average = 0.4 * draw_equal_value_prob + 0.6 * draw_equal_prob_prob
		home_prob = (100 * home_weighted_average).round
		draw_prob = (100 * draw_weighted_average).round
		away_prob = 100 - home_prob - draw_prob
		[home_prob,draw_prob,away_prob]
	end

	def get_next_goal_text(odds, current_goals)
		if odds["goal_line"] == 0
			"We are not so sure about the goals.. you?"
		else
			remaining_time_goals = odds["goal_line"] - current_goals 
			if remaining_time_goals > 1 
				"Will we see at least #{(remaining_time_goals+0.5).to_i} more goals?"
			else
				"Will we see another goal?"
			end
		end
	end

	

	def get_live_stats(event_id)
		if ($redis.hgetall "live_stats").key? event_id.to_s
			marathon_hash = JSON.parse($redis.hget "live_stats", event_id.to_s)
			custom_stat_hash = {}
			custom_stat_hash["Possession"] = marathon_hash["POSSESSION"] if marathon_hash.key? "POSSESSION"
			custom_stat_hash["Corners"] = marathon_hash["CORNER"] if marathon_hash.key? "CORNER"
			custom_stat_hash["Yellow Cards"] = marathon_hash["YELLOW_CARD"] if marathon_hash.key? "YELLOW_CARD"
			custom_stat_hash["Substitutions"] = marathon_hash["SUBSTITUTION"] if marathon_hash.key? "SUBSTITUTION"
			custom_stat_hash["Attacks"] = marathon_hash["ATTACK"] if marathon_hash.key? "ATTACK"
			custom_stat_hash["Dangerous Attacks"] = marathon_hash["DANGEROUS_ATTACK"] if marathon_hash.key? "DANGEROUS_ATTACK"
			custom_stat_hash["Shots"] = marathon_hash["SHOT"] if marathon_hash.key? "SHOT"
			custom_stat_hash["Shots on target"] = marathon_hash["SHOT_ON_TARGET"] if marathon_hash.key? "SHOT_ON_TARGET"
			custom_stat_hash
		else
			{
				"Possession"=>{"t1"=>0, "t2"=>0},
     			"Corners"=>{"t1"=>0, "t2"=>0},
     			"Yellow Cards"=>{"t1"=>0, "t2"=>0},
     			"Substitutions"=>{"t1"=>0, "t2"=>0},
     			"Attacks"=>{"t1"=>0, "t2"=>0},
     			"Dangerous Attacks"=>{"t1"=>0, "t2"=>0},
     			"Shots"=>{"t1"=>0, "t2"=>0},
     			"Shots on target"=>{"t1"=>0, "t2"=>0},
     		}
		end
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
		$redis.set "events_with_live_status", event_ids.to_json
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



	def seed_live_hash
		live_events_hash = {}
		live_events_hash["Colombia"] = {}
		live_events_hash["Colombia"]["Postobon"] = {}
		live_events_hash["Colombia"]["Postobon"]["1"] = {
			home_team: "Envigado",
			away_team: "Medellin",
			minute: 12,
			home_goals: 2,
			away_goals: 0,
			home_red: 0,
			away_red: 1,
			home_prob: 70,
			draw_prob: 20,
			away_prob: 10
		}
		live_events_hash["Colombia"]["Postobon"]["2"] = {
			home_team: "Nacional",
			away_team: "Millionarios",
			minute: 40,
			home_goals: 1,
			away_goals: 0,
			home_red: 0,
			away_red: 0,
			home_prob: 65,
			draw_prob: 20,
			away_prob: 15
		}
		live_events_hash
	end
end