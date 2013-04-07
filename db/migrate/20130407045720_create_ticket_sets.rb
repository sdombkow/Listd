class CreateTicketSets < ActiveRecord::Migration
  def change
    create_table :ticket_sets do |t|
      t.integer :fecha_id
      t.integer :total_released_tickets
      t.integer :sold_tickets
      t.integer :unsold_tickets
      t.decimal :revenue_total
      t.decimal :revenue_percentage

      t.timestamps
    end
  end
end
