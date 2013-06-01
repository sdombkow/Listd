class AddRevenueTotalToWeekPasses < ActiveRecord::Migration
  def change
    add_column :week_passes, :revenue_total, :decimal
  end
end
