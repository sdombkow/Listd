class CreateDia < ActiveRecord::Migration
  def change
    create_table :dia do |t|
      t.integer :location_id
      t.boolean :selling_passes
      t.boolean :selling_reservations
      t.boolean :selling_tickets
      t.boolean :selling_deals

      t.timestamps
    end
  end
end
