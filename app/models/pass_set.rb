class PassSet < ActiveRecord::Base
  
  validates :date, :total_released_passes, :price, :presence => true
  validates_numericality_of :price, :greater_than_or_equal_to =>0, :message => " Invalid Price"
  validates :bar, :presence => true
  
  belongs_to :bar
  has_many :passes , :dependent => :delete_all
  has_many :users, :through => :passes
  has_many :time_periods, :dependent => :destroy 
  
  accepts_nested_attributes_for :time_periods

end