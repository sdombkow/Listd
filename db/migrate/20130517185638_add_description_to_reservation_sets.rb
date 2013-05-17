class AddDescriptionToReservationSets < ActiveRecord::Migration
  def change
    add_column :reservation_sets, :description, :text
  end
end
