class AvailableTimes < ActiveRecord::Base
  attr_accessible :reservation_set_id, :reservation_time, :tables_available, :tables_sold, :tables_unsold
end
