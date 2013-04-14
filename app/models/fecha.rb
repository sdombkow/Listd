class Fecha < ActiveRecord::Base
  
  attr_accessible :location_id, :selling_deals, :selling_passes, :selling_reservations, :selling_tickets, :ticket_set_id, :date
  
  validates :date, :presence => true
  
  belongs_to :location
  belongs_to :ticket_set
  has_one :pass_set

end