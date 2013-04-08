class AddTotalPriceToPasses < ActiveRecord::Migration
  def change
    add_column :passes, :total_price, :decimal
  end
end
