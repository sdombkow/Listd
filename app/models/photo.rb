class Photo < ActiveRecord::Base
  
  attr_accessible :description, :file_name, :location_id
  
  validates :description, :file_name, :location_id, :presence => true
  
  belongs_to :location
  belongs_to :event
  
end