class Odd < ApplicationRecord
	belongs_to :event
	
	def self.get_info(event_id)
		#To do
	end

	def self.update_live_status
		updates = self.check_for_changes_in_live_status
		Event.update_active_record_live_status(updates)
		updates
	end

	def self.get_live_ids
		get_ids_of_live_events
	end

	def self.check_for_changes_in_live_status
		update_live_hash = {}
		new_ids = self.get_live_ids
		update_live_events = {
			add: new_ids - $live_events,
			delete: $live_events - new_ids
		}
		$live_events = new_ids
		update_live_events
	end

	def self.get_live_from_g
		odds_live_inwt = get_all_odds_from_genius
	end

end