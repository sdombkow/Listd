class AddFriendCheckToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :friend_check, :boolean
  end
end
