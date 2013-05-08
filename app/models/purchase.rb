class Purchase < ActiveRecord::Base
  
  attr_accessor :num_passes,:name, :stripe_card_token, :bar, :pass_set, :price, :reservation_time, :location, :ticket_set, :deal_set, :reservation_set, :event
  attr_accessible :stripe_card_token, :name, :date, :num_passes, :pass_set, :bar, :price, :reservation_time, :location, :ticket_set, :deal_set, :reservation_set, :event
  
  validates :name, :price, :num_passes, :date, :presence => true
  validates :name, :format => {:with => /(\w+\s)(\w+-?.?\w?\s?)+/, :message => "Name is not valid"}
  validates :num_passes, :numericality => { :greater_than => 0 }
  
  belongs_to :user
  has_many :passes
  has_many :tickets
  has_many :deals
  has_many :reservations
  
  def payment(user)
      if valid?
          charge = Stripe::Charge.create(
              :amount => price, # amount in cents, again
              :currency => "usd",
              :card => stripe_card_token,
              :description => "payinguser@example.com"
              )
          self.stripe_charge_token = charge.id
          save!
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Purchase not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
  end
    
  def payment_return_customer(user)
      if valid?
          charge = Stripe::Charge.create(
              :amount => price, # amount in cents, again
              :currency => "usd",
              :customer => user.stripe_customer_token
              )
          self.stripe_charge_token = charge.id
          save!
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Purchase not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
  end
    
  def save_with_payment(user)
      if valid?
          customer = Stripe::Customer.create(
              :card => stripe_card_token,
              :description => name
          )
          user.stripe_customer_token = customer.id
          user.save
          charge = Stripe::Charge.create(
              :amount => price, # amount in cents, again
              :currency => "usd",
              :customer => user.stripe_customer_token
          )
          self.stripe_charge_token = charge.id
          save!
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Purchase not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
  end
    
  def return_customer_save_payment(user)
      if valid?
          cu = Stripe::Customer.retrieve(user.stripe_customer_token)
          cu.card = stripe_card_token
          cu.save
          charge = Stripe::Charge.create(
              :amount => price, # amount in cents, again
              :currency => "usd",
              :customer => user.stripe_customer_token
          )
          self.stripe_charge_token = charge.id
          save!
      end
      rescue Stripe::CardError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Purchase not succesful. #{e.message}."
          false
      rescue Stripe::InvalidRequestError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful due to invalid parameters. Please try again later."
          false
      rescue Stripe::AuthenticationError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
      rescue Stripe::APIConnectionError => e
          logger.error "Stripe error while creating customer: #{e.message}"
          user.error_message =  "Sorry, there was a problem with our server. Please try again."
          false
      rescue => e
          user.error_message = "Your purchase was not succesful. Please try again later."
          false
      end
      
  def integer_convert(amount)
      total = Integer(amount)
      total = total*100
      total = total*Integer(num_passes)
      return total
  end
end