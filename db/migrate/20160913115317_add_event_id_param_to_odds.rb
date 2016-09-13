class AddEventIdParamToOdds < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :event_id, :integer
  end
end
