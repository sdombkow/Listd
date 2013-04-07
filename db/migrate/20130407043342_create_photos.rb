class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :location_id
      t.string :file_name
      t.text :description

      t.timestamps
    end
  end
end
