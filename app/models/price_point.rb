class PricePoint < ActiveRecord::Base
  attr_accessible :description, :num_released, :num_sold, :num_unsold, :pass_set_id, :price, :reservation_set_id, :reservation_set_id, :ticket_set_id
end
