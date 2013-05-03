class AddEventToTicketSets < ActiveRecord::Migration
  def change
    add_column :ticket_sets, :event_id, :integer
  end
end
