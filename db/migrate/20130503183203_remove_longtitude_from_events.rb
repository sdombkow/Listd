class RemoveLongtitudeFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :longtitude
  end

  def down
    add_column :events, :longtitude, :float
  end
end
