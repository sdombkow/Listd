class AddSellingPassesToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :selling_passes, :boolean
  end
end
