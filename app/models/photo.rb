class Photo < ActiveRecord::Base
  attr_accessible :description, :file_name, :location_id
end
