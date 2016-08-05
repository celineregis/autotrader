class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
    	t.integer 	:league_id
    	t.integer 	:pp_event_id
    	t.string 	:home
    	t.string 	:away
    	t.datetime 	:event_start
    	t.integer 	:home_goals
    	t.integer 	:away_goals
    	
    	t.timestamps
    end
  end
end
