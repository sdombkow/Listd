class Bar < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_city, :use => :slugged
  
  attr_accessible :address, :latitude, :longitude, :name, :phone_number, :logo, :intro_paragraph, :website_url, 
  :facebook_url,:twitter_url,:open_monday, :open_tuesday,:open_wednesday,:open_thursday,:open_saturday,
  :open_sunday,:houropen_monday,:houropen_tuesday,:hourclose_tuesday,:hourclose_wednesday,:houropen_wednesday,
  :houropen_thursday,:hourclose_thursday,:houropen_friday,:hourclose_friday,:houropen_saturday,:hourclose_saturday,
  :hourclose_sunday,:open_friday,:hourclose_monday,:houropen_sunday, :street_address, :city, :state, :zip_code
  
  validates_uniqueness_of :name, :scope => :city
  validates :phone_number,  :uniqueness => true, :presence => true
  validates :street_address, :city, :state, :zip_code, :presence => true
  validates_format_of :phone_number, 
                    :with => /\A[0-9]{10}\Z/, 
                    :allow_blank => true, 
                    :allow_nil => true
                    
	has_many :pass_sets, :dependent => :destroy
	belongs_to :user
	
	accepts_nested_attributes_for :pass_sets, :allow_destroy => true
	
	geocoded_by :address
	after_validation :geocode, :if => :address_changed?

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