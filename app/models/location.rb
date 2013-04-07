class Location < ActiveRecord::Base
  attr_accessible :city, :facebook_url, :full_address, :intro_paragraph, :latitude, :logo, :longtitude, :name, :phone_number, :slug, :state, :street_address, :twitter_url, :user_id, :website_url, :zip_code
end
