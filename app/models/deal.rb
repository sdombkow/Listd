class Deal < ActiveRecord::Base
  extend FriendlyId
  friendly_id :confirmation
  
  attr_accessible :confirmation, :deal_set_id, :entries, :name, :price, :purchase_id, :redeemed
  
  validates :confirmation, :deal_set_id, :entries, :name, :price, :purchase_id, :redeemed, :presence => true
  validates :confirmation, :uniqueness => true

  belongs_to :deal_set
  belongs_to :purchase
  has_many :friend_purchases

end