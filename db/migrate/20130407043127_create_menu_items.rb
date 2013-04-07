class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.integer :location_id
      t.string :name
      t.decimal :price
      t.text :description

      t.timestamps
    end
  end
end
