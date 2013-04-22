class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_city, :use => :slugged
  
  attr_accessible :city, :facebook_url, :full_address, :intro_paragraph, :latitude, :logo, :longtitude, 
  :name, :phone_number, :slug, :state, :street_address, :twitter_url, :user_id, :website_url, :zip_code
  
  validates_uniqueness_of :name, :scope => :city
  validates :phone_number,  :uniqueness => true, :presence => true
  validates :street_address, :city, :state, :zip_code, :full_address, :name, :user_id, :presence => true
  validates_format_of :phone_number, 
                    :with => /\A[0-9]{10}\Z/, 
                    :allow_blank => true, 
                    :allow_nil => true
                    
	has_many :fechas, :dependent => :destroy
	has_many :ticket_sets, :dependent => :destroy
	has_many :pass_sets, :dependent => :destroy
	has_many :deal_sets, :dependent => :destroy
	has_many :reservation_sets, :dependent => :destroy
	
	has_many :location_hours, :dependent => :destroy
	belongs_to :user
	
	accepts_nested_attributes_for :location_hours, :allow_destroy => true
	
	geocoded_by :full_address
	after_validation :geocode, :if => :full_address_changed?

	def self.search(search)
	  search_condition = "%" + search + "%"
	  @list1 = find(:all, :conditions => ['upper(name) LIKE ?', search_condition.upcase])
	  @list2 = find(:all, :conditions => ['upper(city) LIKE ?', search_condition.upcase])
	  @list1|@list2
	end
	
	def name_city
      "#{name} #{city}"
  end
  
end
