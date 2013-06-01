class WeekPass < ActiveRecord::Base
  attr_accessible :bar_id, :week_cost, :week_total_released, :week_total_sold, :week_total_unsold
  
  validates :week_total_released, :week_cost, :bar, :presence => true
  validates_numericality_of :week_cost, :greater_than_or_equal_to =>0, :message => " Invalid Price"
  
  belongs_to :bar
  has_many :weekly_passes , :dependent => :delete_all
  has_many :users, :through => :passes
end
