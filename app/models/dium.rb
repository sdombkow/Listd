class Dium < ActiveRecord::Base
  attr_accessible :location_id, :selling_deals, :selling_passes, :selling_reservations, :selling_tickets
end
