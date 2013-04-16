class AddPassSetToFecha < ActiveRecord::Migration
  def change
    add_column :fechas, :pass_set_id, :integer
  end
end
