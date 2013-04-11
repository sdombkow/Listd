class TicketSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_tickets, :total_released_tickets, 
  :unsold_tickets
  
  validates :fecha, :date, :total_released_tickets, :revenue_percentage, :sold_tickets,
  :unsold_tickets, :presence => true
  
  belongs_to :fecha
  has_many :tickets , :dependent => :delete_all
  has_many :users, :through => :tickets

end