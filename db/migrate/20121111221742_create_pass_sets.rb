class CreatePassSets < ActiveRecord::Migration
  def change
    create_table :pass_sets do |t|
      t.references :bar
      t.datetime :date
      t.integer :total_released_passes
      t.integer :sold_passes
      t.integer :unsold_passes
      t.decimal :price

      t.timestamps
    end
    add_index :pass_sets, :bar_id
  end
end
