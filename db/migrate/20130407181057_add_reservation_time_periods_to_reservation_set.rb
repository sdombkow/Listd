class AddReservationTimePeriodsToReservationSet < ActiveRecord::Migration
  def change
    add_column :reservation_sets, :reservation_time_periods, :boolean
  end
end
