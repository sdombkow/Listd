class RemoveLongtitudeFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :longtitude
  end

  def down
    add_column :locations, :longtitude, :float
  end
end
