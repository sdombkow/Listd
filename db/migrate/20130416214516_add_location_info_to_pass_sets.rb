class AddLocationInfoToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :location_id, :integer
    add_column :pass_sets, :fecha_id, :integer
  end
end
