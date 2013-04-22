class Reservation < ActiveRecord::Base
  extend FriendlyId
  friendly_id :confirmation
  
  attr_accessible :confirmation, :entries, :name, :price, :purchase_id, :redeemed, :reservation_set_id, :reservation_time
  
  validates :confirmation, :reservation_set_id, :entries, :name, :price, :purchase_id, :presence => true
  validates :confirmation, :uniqueness => true

  belongs_to :reservation_set
  belongs_to :purchase
  has_many :friend_purchases

end