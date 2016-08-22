class Event < ApplicationRecord
	has_many :odds
	belongs_to :league
	validates :pp_event_id, presence: true, uniqueness: true
	validates_format_of :home, without: /Corner/
	validates_format_of :home, without: /Corners/

	def self.update_events(seed_mode = false)
		update_events_m(seed_mode)
	end

	def self.update_active_record_live_status(updates)
		
		updates[:add].each do |event_id|
			event = Event.find_by(pp_event_id: event_id)
			if event
				event.is_live = true
				event.save
			end
		end
		updates[:delete].each do |event_id|
			event = Event.find_by(pp_event_id: event_id)
			if event
				event.is_live = false
				event.save
			end
		end
		playing_minutes = updates[:playing_minutes]
		updates[:ids].each_with_index do|id, index|
			event = Event.find_by(pp_event_id: id)
			if event
				event.playing_minute = playing_minutes[index]
				event.save
			end
		end
	end

end