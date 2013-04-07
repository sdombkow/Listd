class CreateFriendPurchases < ActiveRecord::Migration
  def change
    create_table :friend_purchases do |t|
      t.integer :pass_id
      t.integer :deal_id
      t.integer :ticket_id
      t.integer :reservation_id
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
