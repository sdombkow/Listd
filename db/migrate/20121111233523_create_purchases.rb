class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.date :date
      t.references :user

      t.timestamps
    end
    add_index :purchases, :user_id
  end
end
