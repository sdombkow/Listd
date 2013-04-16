class PassSet < ActiveRecord::Base
  
  validates :total_released_passes, :presence => true
  
  belongs_to :bar
  has_many :passes , :dependent => :delete_all
  has_many :users, :through => :passes
  has_many :time_periods, :dependent => :destroy
  
  belongs_to :location
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :time_periods
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point

end