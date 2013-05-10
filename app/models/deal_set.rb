class DealSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_deals, 
  :total_released_deals, :unsold_deals, :fecha_attributes, :price_point_attributes
  
  validates :fecha, :total_released_deals, :presence => true
  validates :unsold_deals, :numericality => { :greater_than_or_equal_to => 0 }
  
  has_many :deals, :dependent => :delete_all
  has_many :users, :through => :tickets
  
  belongs_to :location
  belongs_to :event
  
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point

end