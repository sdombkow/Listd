class PricePoint < ActiveRecord::Base
  
  attr_accessible :description, :num_released, :num_sold, :num_unsold, :pass_set_id, :price, 
  :reservation_set_id, :reservation_set_id, :ticket_set_id

  validates :num_released, :num_sold, :num_unsold, :price, :presence => true
  validates_numericality_of :price, :greater_than_or_equal_to =>0, :message => " Invalid Price"
  
  belongs_to :pass
  belongs_to :ticket
  belongs_to :reservation
  belongs_to :deal
  
end
