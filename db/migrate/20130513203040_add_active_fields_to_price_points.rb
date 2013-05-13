class AddActiveFieldsToPricePoints < ActiveRecord::Migration
  def change
    add_column :price_points, :active_less_than, :integer
    add_column :price_points, :active_check, :boolean
  end
end
