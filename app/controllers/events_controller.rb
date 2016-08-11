class EventsController < ApplicationController

	def show
		match_id = params[:id]
		@event = Event.find_by(id: match_id)
		@odds_info = Odd.get_info(match_id)

	end
end
