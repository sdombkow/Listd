class AddLocationToTicketSets < ActiveRecord::Migration
  def change
    add_column :ticket_sets, :location_id, :integer
  end
end
