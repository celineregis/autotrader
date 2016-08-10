class SiteController < ApplicationController

	def menu
		@events_hash = League.get_leagues_with_event
	end

	def update
		updates = Odd.update_live_status
		render json: updates
	end

end

