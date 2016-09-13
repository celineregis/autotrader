class AddOddsToOdds < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :tipico_odd, :float
    add_column :odds, :reference_odd, :float
  end
end
