class RemoveHomeOddFromOdds < ActiveRecord::Migration[5.0]
  def change
    remove_column :odds, :home_odd, :float
    remove_column :odds, :draw_odd, :float
    remove_column :odds, :away_odd, :float
  end
end
