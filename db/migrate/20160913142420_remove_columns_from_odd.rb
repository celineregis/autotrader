class RemoveColumnsFromOdd < ActiveRecord::Migration[5.0]
  def change
    remove_column :odds, :event_id, :integer
    remove_column :odds, :pp_event_id, :integer
    remove_column :odds, :market_name, :string
    remove_column :odds, :paramater, :string
    remove_column :odds, :choice_param, :string

  end
end

