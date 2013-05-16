class RemovePriceFromPasses < ActiveRecord::Migration
  def up
    remove_column :passes, :price
  end

  def down
    add_column :passes, :price, :integer
  end
end
