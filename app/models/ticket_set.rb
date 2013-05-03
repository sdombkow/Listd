class TicketSet < ActiveRecord::Base
  
  attr_accessible :revenue_percentage, :revenue_total, :sold_tickets, :total_released_tickets, 
  :unsold_tickets, :fecha_attributes, :price_point_attributes
  
  validates :total_released_tickets, :revenue_percentage, :sold_tickets, :unsold_tickets, :presence => true
  
  has_many :tickets , :dependent => :delete_all
  has_many :users, :through => :tickets
  
  belongs_to :location
  belongs_to :event
  
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point
  
end