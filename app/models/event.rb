class Event < ActiveRecord::Base
  attr_accessible :address, :city, :date_of_event, :facebook_url, :intro_paragraph, :latitude, :logo, :longtitude, :name, :phone_number, :slug, :state, :street_address, :time_of_event, :twitter_url, :user_id, :website_url, :zip_code
end
