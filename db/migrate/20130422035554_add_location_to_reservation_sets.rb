class AddLocationToReservationSets < ActiveRecord::Migration
  def change
    add_column :reservation_sets, :location_id, :integer
  end
end
