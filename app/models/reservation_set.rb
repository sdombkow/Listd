class ReservationSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_reservations, 
  :total_released_reservations, :unsold_reservations, :fecha_attributes, :price_points_attributes
  
  validates :fecha, :total_released_reservations, :presence => true
  validates :unsold_reservations, :numericality => { :greater_than_or_equal_to => 0 }
  
  has_many :reservations, :dependent => :delete_all
  has_many :users, :through => :reservations
  
  belongs_to :location
  belongs_to :event
  
  has_one :fecha
  has_many :price_points, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_points, :reject_if => lambda { |a| a[:price].blank? }, :allow_destroy => true

end