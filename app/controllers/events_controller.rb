class EventsController < ApplicationController

	def show
		match_id = params[:id]
		@event = Event.find_by(id: match_id)
		@odds_info = Odd.get_odds_for_event(match_id)
	end

	def update
		match_id = params[:id]
		binding.pry
		render json: updates
	end
end
