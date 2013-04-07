class CreateSpecials < ActiveRecord::Migration
  def change
    create_table :specials do |t|
      t.integer :location_id
      t.string :name
      t.decimal :price
      t.date :available_start
      t.date :available_end
      t.text :description

      t.timestamps
    end
  end
end
