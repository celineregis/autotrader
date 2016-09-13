class CreateSelections < ActiveRecord::Migration[5.0]
  def change
    create_table :selections do |t|
    	
    	t.integer 	:event_id
    	t.integer 	:pp_event_id
    	t.string    :market_name
    	t.string    :paramater
    	t.string	:choice_paramater
     	t.timestamps
    end
  end
end
