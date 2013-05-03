class ReservationSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_reservations, 
  :total_released_reservations, :unsold_reservations, :fecha_attributes, :price_point_attributes
  
  validates :fecha, :total_released_reservations, :presence => true
  
  has_many :reservations, :dependent => :delete_all
  has_many :users, :through => :reservations
  
  belongs_to :location
  belongs_to :event
  
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point

end