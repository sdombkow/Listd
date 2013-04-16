class AddPercentToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :revenue_percentage, :decimal
  end
end
