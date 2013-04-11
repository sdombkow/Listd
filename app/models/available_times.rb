class AvailableTimes < ActiveRecord::Base
  
  attr_accessible :reservation_set_id, :reservation_time, :tables_available, :tables_sold, :tables_unsold
  
  validates :reservation_set_id, :reservation_time, :tables_available, :tables_sold, :tables_unsold, :presence => true

  belongs_to :reservation_set
  
end