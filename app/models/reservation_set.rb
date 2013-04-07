class ReservationSet < ActiveRecord::Base
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_reservations, :total_released_reservations, :unsold_reservations
end
