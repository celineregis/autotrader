class CreateBets < ActiveRecord::Migration[5.0]
  def change
    create_table :bets do |t|

      t.timestamps
    end
  end
end
