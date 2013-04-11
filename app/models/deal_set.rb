class DealSet < ActiveRecord::Base
  
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_deals, 
  :total_released_deals, :unsold_deals
  
  validates :fecha, :revenue_percentage, :revenue_total :sold_deals, :unsold_deals, 
  :total_released_deals, :fecha, :presence => true
  
  belongs_to :fecha
  has_many :deals , :dependent => :delete_all
  has_many :users, :through => :deals

end