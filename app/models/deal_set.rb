class DealSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_deals, 
  :total_released_deals, :unsold_deals, :fecha_attributes, :price_point_attributes
  
  validates :fecha, :total_released_deals, :presence => true
  
  has_many :deals, :dependent => :delete_all
  has_many :users, :through => :tickets
  belongs_to :location
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point

end