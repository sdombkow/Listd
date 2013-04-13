class AddTicketSetIdToFechas < ActiveRecord::Migration
  def change
    add_column :fechas, :ticket_set_id, :integer
  end
end
