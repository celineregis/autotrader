require "pstore"

module UpdatePre

	def update_leagues_m
		league_response = get_leagues
		league_hash  ||= {}
		league_response.each do |line|
	       	l = League.new
	       	group = line["name"].split(' - ').length == 2 ? line["name"].split(' - ').first.force_encoding('ISO-8859-1') : "Other"
			l.name = line["name"].split(' - ').last.force_encoding('ISO-8859-1')
			l.group = group
			l.pp_league_id = line["id"]
			if l.save
				puts "Saved #{line["name"].split(' - ').last.force_encoding('ISO-8859-1')}"
			else
				puts "Did not save"
			end
		end
	end

	def update_events_m
		event_token = get_event_token
		result_array = get_fixtures(0, 0,event_token)
		unless result_array.nil?
			events_list = result_array[0]
			events_list.each do |league|
				l = League.find_by pp_league_id: league["id"]
				league["events"].each do |event|
				 	l.events.create(
				 		pp_event_id: event["id"],
				 		event_start: event["starts"],
				 		home: event["home"],
				 		away: event["away"],
				 	)
				end
			end
		end
		store_event_token(result_array[1])
	end

	def get_event_token
		tokens = PStore.new("tokens.pstore")
		event_token = ""
		tokens.transaction(true) do 
			event_token = tokens.fetch(:event_token).to_s
		end
		event_token
	end

	def store_event_token(event_token)
		tokens = PStore.new("tokens.pstore")
		tokens.transaction do 
			tokens[:event_token] = event_token
		end
	end

	# def update_odds_m
	# 	#result_array = get_odds(0, 0,"")
	# 	result_array = get_odds(0, 0,$redis.get("odds_token"))
	# 	if result_array[0].nil? && result_array[1].nil?
	# 		puts "The API call was unsucceful, returned nil"
	# 	else
	# 		odds_list = result_array[0]
	# 		$redis.set("odds_token", result_array[1])
	# 		begin 
	# 			current_odds_hash = JSON.parse($redis.get "odds")
	# 		rescue
	# 			current_odds_hash = {}
	# 		end
	# 		odds_list.each do |league|
	# 			league["events"].each do |event|
	# 				event["periods"].each do |period|
	# 					if period["number"] == 0 && period["moneyline"] 
	# 						over_under_line = get_over_under_line_pre(period)
	# 						current_odds_hash[event["id"]] = {
	# 							home_odd: period["moneyline"]["home"],
	# 							draw_odd: period["moneyline"]["draw"],
	# 							away_odd: period["moneyline"]["away"],
	# 							over_odd: over_under_line["over"],
	# 							under_odd: over_under_line["under"],
	# 							over_under_line: over_under_line["points"]
	# 						}
	# 						current_odds_hash
	# 					end
	# 				end
	# 			end
	# 		end
	# 		$redis.set "odds", current_odds_hash.to_json
	# 	end
	# end
	
	# def get_odds_map_update
	# 	events_to_delete = manage_event_hashes_for_expiration
	# 	events_to_update = {}
	# 	all_leagues = JSON.parse($redis.get "leagues")
	# 	all_events = JSON.parse($redis.get "events")
	# 	all_odds = JSON.parse($redis.get "odds")
	# 	map = JSON.parse($redis.get "odds_map")
	# 	#map = {}
	# 	all_events.each do |event_id, event|
	# 		league = all_leagues[event["league_id"].to_s]
	# 		odds = all_odds[event_id]
	# 		if league && odds
	# 			map[league["group"]] ||= {} 
	# 			map[league["group"]][league["name"]] ||= {} 
	# 			#Check if this event already exists in the map and if the odds really changed
	# 			event_in_map = map[league["group"]][league["name"]][event_id]
	# 			unless event_in_map && odds_for_event_still_the_same?(event_in_map, odds)
	# 				match = create_match_hash(event, odds)
	# 				events_to_update[event_id] = match
	# 				map[league["group"]][league["name"]][event_id] = match
	# 			end
	# 		end
	# 	end
	# 	$redis.set("odds_map", map.to_json)
	# 	updates = {
	# 		delete: events_to_delete, 
	# 		update: events_to_update,
	# 	}
	# end

	def manage_event_hashes_for_expiration
		delete_old_events_from_odds_map
		events_to_delete = JSON.parse($redis.get "events").select{|key,event| DateTime.parse(event["starts"]) < DateTime.now.utc}
		move_started_events_to_in_play(events_to_delete) if events_to_delete.length > 0
		current_events = JSON.parse($redis.get "events")
		current_events.delete_if{|key,event| DateTime.parse(event["starts"]) < DateTime.now.utc}
		current_odds = JSON.parse($redis.get "odds")
		current_odds.delete_if{|k,o| events_to_delete.keys.include? k}
		$redis.set "events", current_events.to_json
		$redis.set "odds", current_odds.to_json
		events_to_delete.keys
	end

	def get_over_under_line_pre(period)
		half_goal_lines = period['totals'].select{|points_line| points_line["points"]%0.5==0 && points_line["points"]%1!=0}
		if half_goal_lines.length>0
			half_goal_lines.min_by{|line| line["points"]}
		else
			{
				"over" => 2.0,
				"under" => 2.0,
				"points" => 0
			}
		end
	end

	def get_over_prob_pre(over, under)
		total_prob = 1/over.to_f + 1/under.to_f
		over_equal_value_prob = 1/(over*total_prob)
		over_equal_prob_prob = 1/over-(total_prob-1)/2
		(100*(over_equal_value_prob+over_equal_prob_prob)/2).round
	end

	

	def delete_old_events_from_odds_map
		begin
			odd_hash = JSON.parse($redis.get "odds_map")
		rescue	
			odd_hash = {}
		end
		odd_hash.each do |country, league_hash|
			league_hash.each do |league,event_hash|
				event_hash.delete_if{|id, info| (DateTime.parse(info["kick_off"]) - 2.hours) < DateTime.now}
			end	
		end
		odd_hash.each{|country, league_hash| league_hash.delete_if{|league, event| event== {}}}
		odd_hash.delete_if{|country, league_hash| league_hash== {}}
		$redis.set "odds_map", odd_hash.to_json
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
	
	private 

	def remove_duplicate_event(event, event_array, league_id)
		cleaned_event_array = event_array.delete_if do |event_id, saved_event|
			saved_event["home"] == event["home"] && saved_event["away"] == event["away"] && saved_event["league_id"] == league_id
		end 
		cleaned_event_array
	end

	def move_started_events_to_in_play(events)
		in_play_events_available = $redis.get "in_play_events"
		in_play_hash = in_play_events_available ? JSON.parse($redis.get "in_play_events") : {}
		events.each do |event_id, event_info|
			in_play_hash[event_id] = event_info
		end
		in_play_hash = clean_up_in_play_event_hash(in_play_hash)
		$redis.set "in_play_events", in_play_hash.to_json
	end

	def clean_up_in_play_event_hash(in_play_hash)
		in_play_hash.delete_if{|key,event| DateTime.parse(event["starts"]) < (DateTime.now.utc - 1.days)}
		in_play_hash
	end
	
	def odds_for_event_still_the_same?(event_in_map, odds)
		event_in_map["home_odd"] == odds["home_odd"] && 
		event_in_map["draw_odd"] == odds["draw_odd"] &&
		event_in_map["away_odd"] == odds["away_odd"]
	end

	def create_match_hash(event, odds)
		probs = convert_odds_to_probabilities(odds)
		over_prob = get_over_prob_pre(odds["over_odd"], odds["under_odd"])
		over_under_text = get_over_under_text_pre(odds["over_under_line"])
		if Rails.env.production?
		 	kick_off = (event["starts"].to_time.localtime + (2*60*60)).to_s(:long)
		else
		 	kick_off = event["starts"].to_time.localtime.to_s(:long)
		end
		if Time.parse(kick_off).today?
			today_string = "yes"
		else
			today_string = "no"
		end
		match = {
			home_team: event["home"],
			away_team: event["away"],
			kick_off: kick_off,
			home_odd: odds["home_odd"],
			draw_odd: odds["draw_odd"],
			away_odd: odds["away_odd"],
			home_prob: probs[0],
			draw_prob: probs[1],
			away_prob: probs[2],
			goal_prob: over_prob,
			goal_text: over_under_text,
			today: today_string
		}
		match
	end

	def get_over_under_text_pre(line)
		if line > 0 
			"Will we see at least #{(line+0.5).to_i} goals?" 
		else
			"Will we see at least 3 goals?"
		end

	end

	
end


