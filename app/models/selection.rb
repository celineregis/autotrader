class Selection < ApplicationRecord
	belongs_to :event
	has_many :odds
	validates :event_id, uniqueness: {scope: [:market_name, :paramater, :choice_paramater]}

	def self.create_selections(event)
		markets = self.get_market_names
		unless Selection.find_by(event_id: event[:id])
			markets.each do |market_type|
				market_type[:params].each do |paramater|
					market_type[:choice].each do |choice_param|
						event.selections.create(
								market_name: market_type[:market],
								event_id: event[:id],
								pp_event_id: event[:pp_event_id],
								paramater: paramater,
								choice_paramater: choice_param
						)
					end
				end
			end
		end
	end

	
	private
	
	def self.get_market_names
		[
		 	{
				market: "Match Winner", 
				params: [""],
				choice: ["1","2","3"]
			},
		 	{
				market: "Double Chance", 
				params: [""],
				choice: ["1","2","3"]
			},
			{
				market: "Handicap Remaining Time",
				params: ["0:1","0:2","1:0","2:0"],
				choice: ["1","2","3"]
			},
			{
				market: "Next Goal", 
				params: [""],
				choice: ["1","2","3"]
			},
			{
				market: "Over Under Remaining Time", 
				params: ["0.5","1.5","2.5"],
				choice: ["1","2"]
			},
			{
				market: "Remaining Time", 
				params: [""],
				choice: ["1","2","3"]
			}
		]
	end
end

