class PassSet < ActiveRecord::Base
  validates_presence_of :date, :total_released_passes, :price
  belongs_to :bar
  
  has_many :passes , :dependent => :delete_all
  has_many :users, :through => :passes
  has_many :time_periods, :dependent => :destroy
  validates_numericality_of :price, :greater_than_or_equal_to =>0, :message => " Invalid Price"
  validates :bar, :presence => true
  accepts_nested_attributes_for :time_periods
  
end
