class PassSet < ActiveRecord::Base

  attr_accessible :revenue_percentage, :fecha_attributes, :price_points_attributes, :total_released_passes
  
  validates :total_released_passes, :presence => true
  validates :unsold_passes, :numericality => { :greater_than_or_equal_to => 0 }
  
  has_many :passes , :dependent => :delete_all
  has_many :users, :through => :passes
  has_many :time_periods, :dependent => :destroy
  has_many :price_points, :dependent => :destroy
  belongs_to :bar
  belongs_to :location
  belongs_to :event
  has_one :fecha
  
  accepts_nested_attributes_for :time_periods
  accepts_nested_attributes_for :fecha
  accepts_nested_attributes_for :price_points, :reject_if => lambda { |a| a[:price].blank? }, :allow_destroy => true

end