class TicketSet < ActiveRecord::Base
  
  attr_accessible :revenue_percentage, :revenue_total, :sold_tickets, :total_released_tickets, 
  :unsold_tickets
  
  validates :total_released_tickets, :revenue_percentage, :sold_tickets, :unsold_tickets, :presence => true
  
  has_many :tickets , :dependent => :delete_all
  has_many :users, :through => :tickets
  belongs_to :location
  has_one :fecha, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  
end