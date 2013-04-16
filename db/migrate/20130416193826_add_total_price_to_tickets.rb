class AddTotalPriceToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :total_price, :decimal
  end
end
