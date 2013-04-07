class Deal < ActiveRecord::Base
  attr_accessible :confirmation, :deal_set_id, :entries, :name, :price, :purchase_id, :redeemed
end
