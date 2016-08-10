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
			event.is_live = true
			event.save
		end
		updates[:delete].each do |event_id|
			event = Event.find_by(pp_event_id: event_id)
			event.is_live = false
			event.save
		end
	end

end