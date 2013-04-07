class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :deal_set_id
      t.integer :purchase_id
      t.string :name
      t.boolean :redeemed
      t.integer :entries
      t.decimal :price
      t.string :confirmation

      t.timestamps
    end
  end
end
