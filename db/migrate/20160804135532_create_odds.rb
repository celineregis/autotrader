class CreateOdds < ActiveRecord::Migration[5.0]
  def change
    create_table :odds do |t|
    	t.integer 	:event_id
    	t.integer 	:pp_event_id
    	t.float 	:home_odd
    	t.float 	:draw_odd
    	t.float 	:away_odd
      	t.timestamps
    end
  end
end
