class AddEventToFecha < ActiveRecord::Migration
  def change
    add_column :fechas, :event_id, :integer
  end
end
