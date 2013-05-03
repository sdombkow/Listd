class AddEventToDealSets < ActiveRecord::Migration
  def change
    add_column :deal_sets, :event_id, :integer
  end
end
