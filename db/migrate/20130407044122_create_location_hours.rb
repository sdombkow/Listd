class CreateLocationHours < ActiveRecord::Migration
  def change
    create_table :location_hours do |t|
      t.integer :location_id
      t.string :day_of_week_open
      t.text :day_of_week_close
      t.time :opening_time
      t.time :closing_time

      t.timestamps
    end
  end
end
