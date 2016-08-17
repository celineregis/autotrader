module Pinnacle
	
	API_ROOT = "https://api.pinnacle.com/"
	FOOTBALL_ID = {sportid: 29}.to_param
	
	
	def get_leagues(last_token=0)
		extension = "v2/leagues?#{FOOTBALL_ID}"
		doc = json_request(extension)
		doc["leagues"]
	end

	def get_live_fixtures_in_pinnacle_offering
		extension = "v1/inrunning"
		json_request(extension)["sports"][0]["leagues"] 
	end

	
	def get_fixtures(league_array, liveOnly, last_token) #returns all events by default, set liveOnly=1 for only live
		extension = "v1/fixtures?#{FOOTBALL_ID}"
		response = event_request(league_array, liveOnly, last_token, extension)
		puts response
		results = []
		unless response.nil?
		 	results << response["league"]
		 	results << response["last"]
		 	results
		end
	end
	
	#returns a array of hashes with {leagueId, }
	def get_odds(league_array, liveOnly, last_token)
		extension = "v1/odds?#{FOOTBALL_ID}" #soccer id = 29
		response = event_request(league_array, liveOnly, last_token, extension, true)
		results = []
		unless response.nil?
		 	results << response["leagues"]
		 	results << response["last"]
		 	results
		end
	end

	private

	def json_request(string)
		conn = Faraday.new(:url => API_ROOT) do |faraday|
  			faraday.response :logger                  # log requests to STDOUT
  			faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  			faraday.response :json, :content_type => /\bjson$/
		end
		conn.basic_auth(USER,PASSWORD)
		conn.get(string).body
	end
	# TODO: make this using hash.to_param
	def event_request(league_array, liveOnly, last_token, extension, odds = false)
		league_extension = league_array == 0 ? "" : "&leagueid=#{league_array.join(',')}"
	 	token_extension = last_token == "" ? "" : "&since=#{last_token}"
	 	live_extension = "&isLive=#{liveOnly}"
	 	odds_format = odds ? "&oddsFormat=DECIMAL" : ""
	 	full_query = extension + league_extension + token_extension + live_extension + odds_format
	 	json_request(full_query)
	end


end

