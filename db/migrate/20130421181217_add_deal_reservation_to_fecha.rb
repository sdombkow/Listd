class AddDealReservationToFecha < ActiveRecord::Migration
  def change
    add_column :fechas, :deal_set_id, :integer
    add_column :fechas, :reservation_set_id, :integer
  end
end
