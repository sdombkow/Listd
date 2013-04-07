class DealSet < ActiveRecord::Base
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_deals, :total_released_deals, :unsold_deals
end
