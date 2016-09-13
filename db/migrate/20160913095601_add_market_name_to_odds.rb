class AddMarketNameToOdds < ActiveRecord::Migration[5.0]
  def change
    add_column :odds, :market_name, :string
    add_column :odds, :paramater, :string
  end
end
