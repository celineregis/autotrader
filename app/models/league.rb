class League < ApplicationRecord
	has_many :events
	validates :pp_league_id, presence: true, uniqueness:true

	def self.update_leagues
		update_leagues_m
	end
end
