class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,:provider, :uid, :stripe_card_token, :stripe_customer_token
  attr_accessor
  has_many :bars, :dependent => :destroy
  has_many :purchases
  has_many :passes, :through => :purchases

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
        rescue Stripe::InvalidRequestError => e
            logger.error "Stripe error while creating customer: #{e.message}"
            errors.add :base, "There was a problem with your credit card."
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
    rescue Stripe::InvalidRequestError => e
        logger.error "Stripe error while creating customer: #{e.message}"
        errors.add :base, "There was a problem with your credit card."
        false
  end
end