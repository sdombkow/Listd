class AddReservationTimeToPasses < ActiveRecord::Migration
  def change
    add_column :passes, :reservation_time, :string
  end
end
