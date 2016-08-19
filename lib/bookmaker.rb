module Bookmaker

	def get_live_hash_inwt(line, home, away, points, over, under)
		string_for_test = "wrapper(eventStartInMinutesAgo=0, redCards=0, matchStatus=1, playingMinute=0, hcpParameter=#{line}, hcpHome=#{home}, hcpAway=#{away}, ouParameter=#{points}, ouOver=#{over}, ouUnder=#{under}, homeGoals=0, awayGoals=0)"
		results = $R.convert "1+1"
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
