class Fecha < ActiveRecord::Base
  
  attr_accessible :location_id, :selling_deals, :selling_passes, :selling_reservations, :selling_tickets, :ticket_set_id, :date, :pass_set_id
  
  validates :date, :presence => true
  
  belongs_to :location
  belongs_to :event
  
  belongs_to :ticket_set
  belongs_to :pass_set
  belongs_to :deal_set
  belongs_to :reservation_set

end