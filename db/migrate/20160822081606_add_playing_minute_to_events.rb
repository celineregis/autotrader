class AddPlayingMinuteToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :playing_minute, :int
    
  end
end
