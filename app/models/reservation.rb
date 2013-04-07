class Reservation < ActiveRecord::Base
  attr_accessible :confirmation, :entries, :name, :price, :purchase_id, :redeemed, :reservation_set_id, :reservation_time
end
