module Genius

	

	def get_all_odds_from_genius
		#(eventStartInMinutesAgo, redCards, matchStatus, playingMinuto, hcpParamater, hcpOdds, ouParameter, ouOdds, homeGoals, awayGoals)
		r = RSRuby.instance
		r.rnorm(100)
		# r.source("/Users/reinierverbeek/Desktop/wrapper_inwt.R")
		# r.wrapper(12, 0, 1, 12, 0.5, 2.12, 1.81, 2.5, 1.72, 2.22, 0, 0)
	end
	

end