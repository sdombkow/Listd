class CreatePricePoints < ActiveRecord::Migration
  def change
    create_table :price_points do |t|
      t.integer :pass_set_id
      t.integer :reservation_set_id
      t.integer :ticket_set_id
      t.integer :reservation_set_id
      t.decimal :price
      t.integer :num_released
      t.integer :num_sold
      t.integer :num_unsold
      t.text :description

      t.timestamps
    end
  end
end
