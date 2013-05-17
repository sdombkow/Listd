class AddDescriptionToDealSets < ActiveRecord::Migration
  def change
    add_column :deal_sets, :description, :text
  end
end
