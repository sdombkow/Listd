class AddDescriptionToTicketSets < ActiveRecord::Migration
  def change
    add_column :ticket_sets, :description, :text
  end
end
