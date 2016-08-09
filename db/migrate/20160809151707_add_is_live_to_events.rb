class AddIsLiveToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :is_live, :boolean, default: false
  end
end
