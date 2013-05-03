class AddEventToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :event_id, :integer
  end
end
