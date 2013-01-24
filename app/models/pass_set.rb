class PassSet < ActiveRecord::Base
  validates_presence_of :date, :total_released_passes, :price
  validates_format_of :price, :with => /\d{0,10}\.\d{2}/
  has_many :passes , :dependent => :delete_all

end
