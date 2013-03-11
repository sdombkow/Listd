class AddReservationTimePeriodsToPassSets < ActiveRecord::Migration
  def change
    add_column :pass_sets, :reservation_time_periods, :boolean
  end
end
