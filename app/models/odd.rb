class Odd < ApplicationRecord
	belongs_to :event
	
	
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

	def self.get_odds_for_event(event_id)
		odds = get_live_odds_by_id(Event.find(event_id).pp_event_id)
		binding.pry
	end

	def self.t
		optimizeTwoWay(200, 100, 1.70, 0.08)
	end

	def self.ex
		get_live_hash_inwt
	end

end