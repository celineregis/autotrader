class Odd < ApplicationRecord
	belongs_to :event
	
	def self.get_info(event_id)
		#To do
	end

	def self.start_the_machine
		Event.update_active_record_live_status(self.check_for_changes_in_live_status)
		@@scheduler_check_live_status = Rufus::Scheduler.new
		@@scheduler_check_live_status.every '1m' do
			updates = self.check_for_changes_in_live_status
			Event.update_active_record_live_status(updates)
			ActionCable.server.broadcast 'odd_channel', updates
		end
	end

	def self.stop_the_machine
		@@scheduler_check_live_status.shutdown
	end

	def self.get_live_ids
		get_ids_of_live_events
	end

	def self.check_for_changes_in_live_status(first_time=false)
		update_live_hash = {}
		new_ids = self.get_live_ids
		update_live_events = {
			add: new_ids - $live_events,
			delete: $live_events - new_ids
		}
		$live_events = new_ids
		update_live_events
	end

	
end
