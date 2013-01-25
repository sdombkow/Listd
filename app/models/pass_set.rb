class PassSet < ActiveRecord::Base
  validates_presence_of :date, :total_released_passes, :price
  belongs_to :bar
  has_many :passes , :dependent => :delete_all
  validates_numericality_of :price, :greater_than_or_equal_to =>0, :message => " Invalid Price"
 
end
