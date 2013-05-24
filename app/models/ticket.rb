class Ticket < ActiveRecord::Base
  extend FriendlyId
  friendly_id :confirmation
  
  attr_accessible :confirmation, :entries, :name, :price, :purchase_id, :redeemed, :ticket_set_id
  
  validates :confirmation, :entries, :name, :price, :purchase_id, :ticket_set_id, :presence => true
  validates :confirmation, :uniqueness => true

  has_many :pass_friends
  belongs_to :ticket_set
  belongs_to :purchase

end