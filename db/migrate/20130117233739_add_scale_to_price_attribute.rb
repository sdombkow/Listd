class AddScaleToPriceAttribute < ActiveRecord::Migration
  def change
      change_column :pass_sets, :price, :decimal, :precision => 10, :scale => 2
  end
end
