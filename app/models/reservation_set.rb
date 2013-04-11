class ReservationSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_reservations, 
  :total_released_reservations, :unsold_reservations
  
  validates :fecha, :date, :total_released_reservations, :sold_reservations, :unsold_reservations, :revenue_total, 
  :revenue_percentage, :presence => true
  
  belongs_to :fecha
  has_many :reservations , :dependent => :delete_all
  has_many :users, :through => :reservations

end