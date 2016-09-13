class AddPpEventIdToOdds < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :pp_event_id, :integer
  end
end
