class AddLocationToDealSets < ActiveRecord::Migration
  def change
    add_column :deal_sets, :location_id, :integer
  end
end
