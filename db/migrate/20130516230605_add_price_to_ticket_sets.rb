class AddPriceToTicketSets < ActiveRecord::Migration
  def change
    add_column :ticket_sets, :price, :decimal
  end
end
