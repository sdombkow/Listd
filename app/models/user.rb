class User < ActiveRecord::Base
  before_save :ensure_authentication_token
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :timeoutable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,:provider, :uid, :stripe_card_token, :stripe_customer_token

  has_many :bars, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :events, :dependent => :destroy
  
  has_many :purchases
  has_many :passes, :through => :purchases
  has_many :tickets, :through => :purchases
  has_many :deals, :through => :purchases
  has_many :reservations, :through => :purchases

  validates :name, :email, :presence => true

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
      user = User.where(:provider => auth.provider, :uid => auth.uid).first
      unless user
          user = User.create(name:auth.extra.raw_info.name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20])
      end
      user
  end

  def self.new_with_session(params, session)
      super.tap do |user|
          if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
              user.email = data["email"] if user.email.blank?
          end
      end
  end
  
  def save_token
      if valid?
          logger.error "Stripe Card Token: #{name} and #{stripe_card_token} and #{stripe_customer_token}"
          cu = Stripe::Customer.retrieve(stripe_customer_token)
          cu.card = stripe_card_token
          cu.save
          logger.error "Stripe Customer Token: #{stripe_customer_token}"
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Card save not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your card save was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your card save was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your card save was not succesful. Please try again later."
          false
  end
  
  def create_token
      if valid?
          logger.error "Stripe Card Token: #{name} and #{stripe_card_token} and #{stripe_customer_token}"
          customer = Stripe::Customer.create(
              :card => stripe_card_token,
              :description => name
              )
          self.stripe_customer_token = customer.id
          self.stripe_card_token = nil
          self.save!
          logger.error "Stripe Customer Token: #{stripe_customer_token}"
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Card save not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your card save was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your card save was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your card save was not succesful. Please try again later."
          false
  end
end