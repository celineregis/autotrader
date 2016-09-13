class AddColumnsFromOdd < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :selection_id, :integer
  end
end
