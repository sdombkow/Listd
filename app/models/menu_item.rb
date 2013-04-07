class MenuItem < ActiveRecord::Base
  attr_accessible :description, :location_id, :name, :price
end
