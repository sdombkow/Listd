class Bar < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name_city, :use => :slugged
  def name_city
    "#{name} #{city}"
  end
  
  validates_uniqueness_of :name, :scope => :city
  validates :phone_number,  :uniqueness => true, :presence => true
  validates_presence_of :street_address, :city, :state, :zip_code
  
  validates_format_of :phone_number, 
                    :with => /\A[0-9]{10}\Z/, 
                    :allow_blank => true, 
                    :allow_nil => true


  attr_accessible :address, :latitude, :longitude, :name, :phone_number, :logo, :intro_paragraph, :website_url, 
  :facebook_url,:twitter_url,:open_monday, :open_tuesday,:open_wednesday,:open_thursday,:open_saturday,
  :open_sunday,:houropen_monday,:houropen_tuesday,:hourclose_tuesday,:hourclose_wednesday,:houropen_wednesday,
  :houropen_thursday,:hourclose_thursday,:houropen_friday,:hourclose_friday,:houropen_saturday,:hourclose_saturday,
  :hourclose_sunday,:open_friday,:hourclose_monday,:houropen_sunday, :street_address, :city, :state, :zip_code

	has_many :pass_sets, :dependent => :destroy
	accepts_nested_attributes_for :pass_sets, :allow_destroy => true
	
	geocoded_by :address
	after_validation :geocode, :if => :address_changed?

	def self.search(search)
	  search_condition = "%" + search + "%"
	  @list1 = find(:all, :conditions => ['upper(name) LIKE ?', search_condition.upcase])
	  @list2 = find(:all, :conditions => ['upper(city) LIKE ?', search_condition.upcase])
	  @list1|@list2
	end

	

	belongs_to :user
end
