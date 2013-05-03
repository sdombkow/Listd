class AddEventToReservationSets < ActiveRecord::Migration
  def change
    add_column :reservation_sets, :event_id, :integer
  end
end
