module Bookmaker

	def get_live_hash_inwt(line, home, away, points, over, under, home_goals, away_goals, playing_minute)
		string_for_test = "wrapper(eventStartInMinutesAgo=0, redCards=0, matchStatus=1, playingMinute=#{playing_minute}, hcpParameter=#{line}, hcpHome=#{home}, hcpAway=#{away}, ouParameter=#{points}, ouOver=#{over}, ouUnder=#{under},homeGoals=#{home_goals}, awayGoals=#{away_goals})"
		puts "Executing R code: #{string_for_test}"
		results = $R.convert string_for_test
		#IO.write('./lib/external_scripts/hash.txt', parse_inwt(results.to_ruby))
		parse_inwt(results.to_ruby)
	end

	def parse_inwt(results)
		hash = {}
		results[0].each_with_index do |value, index|
			hash[results[9][index]] ||= {}
			hash[results[9][index]][results[8][index]] = {
				odds: results[0][index].split('/')
			}
		end
		hash
	end

	

end
