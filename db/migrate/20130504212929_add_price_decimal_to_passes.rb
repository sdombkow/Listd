class AddPriceDecimalToPasses < ActiveRecord::Migration
  def change
    add_column :passes, :price, :decimal
  end
end
