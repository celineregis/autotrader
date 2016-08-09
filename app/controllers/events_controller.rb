class EventsController < ApplicationController

	def show
		match_id = params[:id]
		odds_info = Odd.get_info(match_id)
	end
end
