class CreateWeeklyPasses < ActiveRecord::Migration
  def change
    create_table :weekly_passes do |t|
      t.integer :week_pass_id
      t.integer :purchase_id
      t.string :name
      t.boolean :redeemed
      t.integer :entries
      t.string :confirmation
      t.decimal :price
      t.decimal :total_price

      t.timestamps
    end
  end
end
