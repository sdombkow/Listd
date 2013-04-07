class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.integer :reservation_set_id
      t.integer :purchase_id
      t.string :name
      t.boolean :redeemed
      t.integer :entries
      t.decimal :price
      t.string :confirmation
      t.string :reservation_time

      t.timestamps
    end
  end
end
