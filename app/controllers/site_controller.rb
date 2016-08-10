class SiteController < ApplicationController

	def menu
		@events_hash = League.get_leagues_with_event
	end

	def info

	end
	
end

