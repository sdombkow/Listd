class TicketSet < ActiveRecord::Base
  
  attr_accessible :revenue_percentage, :revenue_total, :sold_tickets, :total_released_tickets, 
  :unsold_tickets, :fecha_attributes, :price_points_attributes
  
  validates :total_released_tickets, :revenue_percentage, :sold_tickets, :unsold_tickets, :presence => true
  validates :unsold_tickets, :numericality => { :greater_than_or_equal_to => 0 }
  
  has_many :tickets , :dependent => :delete_all
  has_many :users, :through => :tickets
  has_many :price_points, :dependent => :destroy
  belongs_to :location
  belongs_to :event
  has_one :fecha
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_points, :reject_if => lambda { |a| a[:price].blank? }, :allow_destroy => true
  
end