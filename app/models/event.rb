class Event < ApplicationRecord
	has_many :odds
	belongs_to :league
	validates :pp_event_id, presence: true, uniqueness: true
	validates_format_of :home, without: /Corner/
	validates_format_of :home, without: /Corners/

	def self.update_events(seed_mode = false)
		update_events_m(seed_mode)
	end
end