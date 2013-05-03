class PassSet < ActiveRecord::Base

  attr_accessible :revenue_percentage, :fecha_attributes, :price_point_attributes, :total_released_passes
  
  validates :total_released_passes, :presence => true
  
  belongs_to :bar
  has_many :passes , :dependent => :delete_all
  has_many :users, :through => :passes
  has_many :time_periods, :dependent => :destroy
  
  belongs_to :location
  belongs_to :event
  
  has_one :fecha, :dependent => :destroy
  has_one :price_point, :dependent => :destroy
  
  accepts_nested_attributes_for :time_periods
  
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_point, :reject_if => lambda { |a| a[:content].blank? }

end