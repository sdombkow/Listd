class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :name
      t.integer :phone_number
      t.string :address
      t.text :intro_paragraph
      t.date :date_of_event
      t.time :time_of_event
      t.float :latitude
      t.float :longtitude
      t.string :logo
      t.string :website_url
      t.string :facebook_url
      t.string :twitter_url
      t.string :street_address
      t.string :city
      t.integer :zip_code
      t.string :state
      t.string :slug

      t.timestamps
    end
  end
end
