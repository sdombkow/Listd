class AddPriceFieldsToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :single_price_level, :boolean
    add_column :pass_sets, :double_price_level, :boolean
    add_column :pass_sets, :triple_price_level, :boolean
    add_column :pass_sets, :double_price_less_than, :integer
    add_column :pass_sets, :triple_price_less_than, :integer
    add_column :pass_sets, :double_price_value, :decimal, :precision => 10, :scale => 2, :default => 0
    add_column :pass_sets, :triple_price_value, :decimal, :precision => 10, :scale => 2, :default => 0
  end
end
