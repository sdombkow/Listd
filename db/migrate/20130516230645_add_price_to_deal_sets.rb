class AddPriceToDealSets < ActiveRecord::Migration
  def change
    add_column :deal_sets, :price, :decimal
  end
end
