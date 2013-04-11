class LocationHour < ActiveRecord::Base
  
  attr_accessible :closing_time, :day_of_week_close, :day_of_week_open, :location_id, :opening_time
  
  validates :closing_time, :day_of_week_close, :day_of_week_open, :location_id, :opening_time, :presence => true
  
  belongs_to :location

end