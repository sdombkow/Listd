class RemoveZipCodeFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :zip_code
  end

  def down
    add_column :events, :zip_code, :integer
  end
end
