class AddTotalPriceToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :total_price, :decimal
  end
end
