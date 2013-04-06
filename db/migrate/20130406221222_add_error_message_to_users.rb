class AddErrorMessageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :error_message, :string
  end
end
