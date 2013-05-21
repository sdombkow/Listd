class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_city, :use => :slugged
  
  attr_accessible :city, :facebook_url, :full_address, :intro_paragraph, :latitude, :logo, :longtitude, 
  :name, :phone_number, :slug, :state, :street_address, :twitter_url, :user_id, :website_url, :zip_code, 
  :location_hours_attributes, :menu_items_attributes, :specials_attributes, :photo
  
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
	has_many :menu_items, :dependent => :destroy
	has_many :specials, :dependent => :destroy
	belongs_to :user
	
	has_attached_file :photo, :styles => { :small => "150x150>" }
	
	accepts_nested_attributes_for :location_hours, :reject_if => lambda { |a| a[:day_of_week_open].blank? }, :allow_destroy => true
	accepts_nested_attributes_for :menu_items, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
	accepts_nested_attributes_for :specials, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
	
	
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