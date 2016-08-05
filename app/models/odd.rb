class Odd < ApplicationRecord
	belongs_to :event
	
	def self.get_events_with_live_odds
		get_live_events_hash
	end
end
