class CurrentUserController < ApplicationController
  
  def delete_stripe_token
    logger.error "Stripe error while creating customer: #{current_user.stripe_customer_token}"
    current_user.update_attribute(:stripe_customer_token,nil)
    current_user.save!
    redirect_to "/users"
  end
  
  def update
    logger.error "Stripe error while creating customer: #{current_user}"
    if current_user.stripe_customer_token != nil
      @user = current_user
      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
      @last_four = @customer_card.active_card.last4
      current_user.save!
    end
  end
end