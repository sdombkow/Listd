class AddDealSetToPricePoint < ActiveRecord::Migration
  def change
    add_column :price_points, :deal_set_id, :integer
  end
end
