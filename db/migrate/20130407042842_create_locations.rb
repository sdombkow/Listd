class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :user_id
      t.string :name
      t.integer :phone_number
      t.string :street_address
      t.text :intro_paragraph
      t.float :latitude
      t.float :longtitude
      t.string :logo
      t.string :website_url
      t.string :facebook_url
      t.string :twitter_url
      t.string :full_address
      t.string :city
      t.string :zip_code
      t.string :state
      t.string :slug

      t.timestamps
    end
  end
end
