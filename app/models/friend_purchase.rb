class FriendPurchase < ActiveRecord::Base
  attr_accessible :deal_id, :email, :name, :pass_id, :reservation_id, :ticket_id
  
  validates :email, :name, :presence => true
  
  belongs_to :deal
  belongs_to :pass
  belongs_to :reservation
  belongs_to :ticket
  
end