class CreatePassFriends < ActiveRecord::Migration
  def change
    create_table :pass_friends do |t|
      t.integer :pass_id
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
