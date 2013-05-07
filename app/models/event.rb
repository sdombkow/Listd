class Event < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_city, :use => :slugged
  
  attr_accessible :address, :city, :date_of_event, :facebook_url, :intro_paragraph, :latitude, :logo, 
  :longtitude, :name, :phone_number, :slug, :state, :street_address, :time_of_event, :twitter_url, 
  :user_id, :website_url, :zip_code
  
  validates_uniqueness_of :name, :scope => :city
  validates :phone_number,  :uniqueness => true, :presence => true
  validates :street_address, :city, :state, :zip_code, :date_of_event, :presence => true
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
	
	accepts_nested_attributes_for :pass_sets, :allow_destroy => true
	accepts_nested_attributes_for :ticket_sets, :allow_destroy => true
	
	geocoded_by :address
	after_validation :geocode, :if => :address_changed?
	
	accepts_nested_attributes_for :location_hours, :reject_if => lambda { |a| a[:day_of_week_open].blank? }, :allow_destroy => true

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