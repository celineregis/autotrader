class League < ApplicationRecord
	has_many :events
	validates :pp_league_id, presence: true, uniqueness:true

	def self.update_leagues
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

	def self.get_leagues_with_event
		events = Event.includes(:league).where(event_start: (Time.zone.now-60*60*2)..Time.zone.now.end_of_day)
		events_hash = {}
		events.each do |event|
			events_hash[event.league.group] ||= {}
			events_hash[event.league.group][event.league.name] ||= []
			events_hash[event.league.group][event.league.name] << event
		end
		events_hash
	end
end
