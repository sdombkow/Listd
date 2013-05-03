class AddEventToLocationHours < ActiveRecord::Migration
  def change
    add_column :location_hours, :event_id, :integer
  end
end
