class CreateLeagues < ActiveRecord::Migration[5.0]
  def change
    create_table :leagues do |t|
    	t.string 	:name
    	t.string 	:group
    	t.integer	:pp_league_id
    	
    	t.timestamps
    end
  end
end
