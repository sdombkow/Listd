class CurrentUserController < ApplicationController
  
  def delete_stripe_token
    logger.error "Stripe error while creating customer: #{current_user.stripe_customer_token}"
    current_user.update_attribute(:stripe_customer_token,nil)
    current_user.save!
    redirect_to :root, notice: 'Card Deleted'
  end
  
  def update
    logger.error "Stripe error while creating customer: #{current_user}"
    if current_user.stripe_customer_token != nil
      @user = current_user
      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
      @last_four = @customer_card.active_card.last4
      @end_month = @customer_card.active_card.exp_month
      @end_month_name = Date::MONTHNAMES[@customer_card.active_card.exp_month]
      @end_year = @customer_card.active_card.exp_year
      logger.error "Last Four: #{@customer_card}"
      current_user.save!
    end
  end
end