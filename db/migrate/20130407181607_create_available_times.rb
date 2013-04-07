class CreateAvailableTimes < ActiveRecord::Migration
  def change
    create_table :available_times do |t|
      t.integer :reservation_set_id
      t.time :reservation_time
      t.integer :tables_available
      t.integer :tables_sold
      t.integer :tables_unsold

      t.timestamps
    end
  end
end
