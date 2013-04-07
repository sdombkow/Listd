class CurrentUserController < ApplicationController
  
  def delete_stripe_token
    logger.error "Current User Stripe Customer Token: #{current_user.stripe_customer_token}"
    current_user.update_attribute(:stripe_customer_token,nil)
    current_user.save!
    redirect_to :root, notice: 'Card Deleted'
  end
  
  def update
    logger.error "Current User: #{current_user}"
    logger.error "Customer Token: #{current_user.stripe_customer_token}"
    if current_user.stripe_customer_token != nil
      @user = current_user
      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
      logger.error "#{@customer_card}"
      if @customer_card.active_card != nil
          @last_four = @customer_card.active_card.last4
          @end_month = @customer_card.active_card.exp_month
          @end_month_name = Date::MONTHNAMES[@customer_card.active_card.exp_month]
          @end_year = @customer_card.active_card.exp_year
          logger.error "Last Four: #{@customer_card}"
      end
      current_user.save!
    end
  end
end