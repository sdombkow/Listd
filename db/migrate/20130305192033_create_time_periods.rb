class CreateTimePeriods < ActiveRecord::Migration
  def change
    create_table :time_periods do |t|
      t.boolean :ten_am_available
      t.integer :ten_am_tables
      t.boolean :ten_thirty_am_available
      t.integer :ten_thirty_am_tables
      t.boolean :eleven_am_available
      t.integer :eleven_am_tables
      t.boolean :eleven_thirty_am_available
      t.integer :eleven_thirty_am_tables
      t.boolean :twelve_pm_available
      t.integer :twelve_pm_tables
      t.boolean :twelve_thirty_pm_available
      t.integer :twelve_thirty_pm_tables
      t.boolean :one_pm_available
      t.integer :one_pm_tables
      t.boolean :one_thirty_pm_available
      t.integer :one_thirty_pm_tables
      t.boolean :two_pm_available
      t.integer :two_pm_tables
      t.boolean :two_thirty_pm_available
      t.integer :two_thirty_pm_tables
      t.boolean :three_pm_available
      t.integer :three_pm_tables
      t.boolean :three_thirty_pm_available
      t.integer :three_thirty_pm_tables
      t.boolean :four_pm_available
      t.integer :four_pm_tables
      t.boolean :four_thirty_pm_available
      t.integer :four_thirty_pm_tables
      t.boolean :five_pm_available
      t.integer :five_pm_tables
      t.boolean :five_thirty_pm_available
      t.integer :five_thirty_pm_tables
      t.boolean :six_pm_available
      t.integer :six_pm_tables
      t.boolean :six_thirty_pm_available
      t.integer :six_thirty_pm_tables
      t.boolean :seven_pm_available
      t.integer :seven_pm_tables
      t.boolean :seven_thirty_pm_available
      t.integer :seven_thirty_pm_tables
      t.boolean :eight_pm_available
      t.integer :eight_pm_tables
      t.boolean :eight_thirty_pm_available
      t.integer :eight_thirty_pm_tables
      t.boolean :nine_pm_available
      t.integer :nine_pm_tables
      t.boolean :nine_thirty_pm_available
      t.integer :nine_thirty_pm_tables
      t.boolean :ten_pm_available
      t.integer :ten_pm_tables
      t.integer :pass_set_id

      t.timestamps
    end
  end
end
