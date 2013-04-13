class AddDateToFechas < ActiveRecord::Migration
  def change
    add_column :fechas, :date, :date
  end
end
