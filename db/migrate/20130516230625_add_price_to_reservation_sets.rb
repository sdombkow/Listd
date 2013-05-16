class AddPriceToReservationSets < ActiveRecord::Migration
  def change
    add_column :reservation_sets, :price, :decimal
  end
end
