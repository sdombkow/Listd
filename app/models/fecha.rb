class Fecha < ActiveRecord::Base
  
  attr_accessible :location_id, :selling_deals, :selling_passes, :selling_reservations, :selling_tickets
  
  validates :location_id, :selling_deals, :selling_passes, :selling_reservations, 
  :selling_tickets, :presence => true
  
  belongs_to :location
  has_many :pass_sets, :dependent => :destroy
  has_many :ticket_sets, :dependent => :destroy
  has_many :reservation_sets, :dependent => :destroy
  has_many :deal_sets, :dependent => :destroy

end