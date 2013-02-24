class AddDescriptionToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :description, :text
  end
end
