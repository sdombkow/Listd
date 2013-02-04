class AddSlugToBars < ActiveRecord::Migration
  def change
    add_column :bars, :slug, :string
  end
end
