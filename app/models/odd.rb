class Odd < ApplicationRecord
	belongs_to :event
	
	def self.get_info(event_id)
		binding.pry
	end
end
