class AddColumnsToBet < ActiveRecord::Migration[5.0]
  def change
    add_column :bets, :odd_id, :integer
    add_column :bets, :stake, :integer
  end
end
