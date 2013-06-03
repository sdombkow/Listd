class AddValidDatesToWeeklyPasses < ActiveRecord::Migration
  def change
    add_column :weekly_passes, :valid_from, :datetime
    add_column :weekly_passes, :valid_to, :datetime
  end
end
