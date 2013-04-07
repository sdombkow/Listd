class CreateReservationSets < ActiveRecord::Migration
  def change
    create_table :reservation_sets do |t|
      t.integer :fecha_id
      t.integer :total_released_reservations
      t.integer :sold_reservations
      t.integer :unsold_reservations
      t.decimal :revenue_total
      t.decimal :revenue_percentage

      t.timestamps
    end
  end
end
