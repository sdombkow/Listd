class Ticket < ActiveRecord::Base
  attr_accessible :confirmation, :entries, :name, :price, :purchase_id, :redeemed, :ticket_set_id
end
