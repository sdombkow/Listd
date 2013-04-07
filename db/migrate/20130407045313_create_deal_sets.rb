class CreateDealSets < ActiveRecord::Migration
  def change
    create_table :deal_sets do |t|
      t.integer :fecha_id
      t.integer :total_released_deals
      t.integer :sold_deals
      t.integer :unsold_deals
      t.decimal :revenue_total
      t.decimal :revenue_percentage

      t.timestamps
    end
  end
end
