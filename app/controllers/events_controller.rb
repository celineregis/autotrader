class EventsController < ApplicationController

	def show
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	
		puts "======================SHOW========================"	

		match_id = params[:id]
		@event = Event.find_by(id: match_id)
		results = Odd.get_odds_for_event(match_id, true)
		@odds_info = results[0]
		@event_info = results[1]
	end

	def update
		match_id = params[:id]
		Event.update_live_status
		@odds_info = Odd.get_odds_for_event(match_id, false)
		render json: @odds_info
	end
end
