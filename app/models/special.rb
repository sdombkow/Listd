class Special < ActiveRecord::Base
  
  attr_accessible :available_end, :available_start, :description, :location_id, :name, :price
  
  validates :available_end, :available_start, :location_id, :name, :price, :presence => true
  
  belongs_to :location
  
end