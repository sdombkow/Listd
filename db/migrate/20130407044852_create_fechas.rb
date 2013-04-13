class CreateFechas < ActiveRecord::Migration
  def change
    create_table :fechas do |t|
      t.integer :location_id
      t.boolean :selling_passes, default: false
      t.boolean :selling_reservations, default: false
      t.boolean :selling_tickets, default: false
      t.boolean :selling_deals, default: false

      t.timestamps
    end
  end
end
