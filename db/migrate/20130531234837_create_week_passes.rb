class CreateWeekPasses < ActiveRecord::Migration
  def change
    create_table :week_passes do |t|
      t.integer :bar_id
      t.integer :week_total_released
      t.integer :week_total_sold
      t.integer :week_total_unsold
      t.decimal :week_cost

      t.timestamps
    end
  end
end
