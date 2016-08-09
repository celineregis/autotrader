class League < ApplicationRecord
	has_many :events
	validates :pp_league_id, presence: true, uniqueness:true

	def self.update_leagues
		update_leagues_m
	end

	def self.get_leagues_with_event
		events = Event.includes(:league).where(event_start: Time.zone.now..Time.zone.now.end_of_day)
		events_hash = {}
		events.each do |event|
			events_hash[event.league.group] ||= {}
			events_hash[event.league.group][event.league.name] ||= []
			events_hash[event.league.group][event.league.name] << event
		end
		events_hash
	end
end
