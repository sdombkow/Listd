class TicketSet < ActiveRecord::Base
  attr_accessible :fecha_id, :revenue_percentage, :revenue_total, :sold_tickets, :total_released_tickets, :unsold_tickets
end
