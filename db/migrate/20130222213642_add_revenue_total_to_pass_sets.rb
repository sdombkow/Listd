class AddRevenueTotalToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :revenue_total, :decimal, :precision => 10, :scale => 2, :default => 0
  end
end
