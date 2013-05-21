class MenuItem < ActiveRecord::Base
  
  attr_accessible :description, :location_id, :name, :price
  
  validates :name, :price, :presence => true
  
  belongs_to :location
  
end