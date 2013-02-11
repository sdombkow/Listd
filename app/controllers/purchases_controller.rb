class PurchasesController < ApplicationController

	
	def create
		@user = current_user
		@bar = Bar.find(params[:purchase][:bar])
		@pass_set = PassSet.find(params[:purchase][:pass_set])
		num_passes = params[:purchase][:num_passes].to_i
		if num_passes > @pass_set.unsold_passes
			flash[:error] = 'Not enough passes left'
			redirect_to [@bar,@pass_set]
			return
		end
		@purchase = Purchase.new(params[:purchase])
		@purchase.user_id = @user.id
		@purchase.date = params[:purchase][:date]
		logger.error "Number: #{@pass_set.price}"
		if Integer(String(@pass_set.price).split(".").last) < 10
		    logger.error "Number: #{Integer(String(@pass_set.price).split(".").last)}"
	      @decimals = String(@pass_set.price).split(".").last+"0"
	      logger.error "Number: #{Integer(String(@pass_set.price).split(".").last)}"+"0"
	  else 
	      @decimals = String(@pass_set.price).split(".").last 
	  end
		@purchase.price = String(@pass_set.price).split(".").first+@decimals
		
		logger.error "Stripe error while creating customer: #{@user.stripe_customer_token}"
		if @user.stripe_customer_token != nil
		    logger.error "Here in not nil"
		    logger.error "#{@user.stripe_card_token}"
		    @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
        @end_month = @customer_card.active_card.exp_month
        @end_year = @customer_card.active_card.exp_year
        logger.error "#{@end_month < Time.now.month}"
        logger.error "#{@end_year < Time.now.year}"
		    if @end_month < Time.now.month or @end_year < Time.now.year
		        redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured. Your current saved card has expired.'
		    end
		    if @purchase.stripe_card_token == ""
		        if @purchase.payment_return_customer(current_user)
		            @pass_set.sold_passes+=num_passes
		            @pass_set.unsold_passes-=num_passes
		            @pass_set.save
		            # for i in 0..num_passes-1
			          pass = Pass.new
			          pass.name = params[:purchase][:name]
			          pass.purchase_id = @purchase.id
			          pass.pass_set_id = @pass_set.id
			          pass.redeemed = false
				        pass.entries=num_passes
				        pass.confirmation=SecureRandom.hex(4)
			          pass.save
			          UserMailer.purchase_confirmation(@user,pass).deliver
                redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
        		else
        		    redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured.'
			      end
		    elsif params[:credit_card_save] == "1"
		      logger.error "Here in 1"
    		  if @purchase.save_with_payment(current_user)
    		      @pass_set.sold_passes+=num_passes
    		      @pass_set.unsold_passes-=num_passes
    		      @pass_set.save
    		      # for i in 0..num_passes-1
    			      pass = Pass.new
    			      pass.name = params[:purchase][:name]
    			      pass.purchase_id = @purchase.id
    			      pass.pass_set_id = @pass_set.id
    			      pass.redeemed = false
    				  pass.entries=num_passes
    				  pass.confirmation=SecureRandom.hex(4)
    			      pass.save
    		      #end
    		UserMailer.purchase_confirmation(@user,pass).deliver
              redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
    		  else
    		      redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured.'
    		  end
		    else
		        if @purchase.payment
		            @pass_set.sold_passes+=num_passes
		            @pass_set.unsold_passes-=num_passes
		            @pass_set.save
		            # for i in 0..num_passes-1
			          pass = Pass.new
			          pass.name = params[:purchase][:name]
			          pass.purchase_id = @purchase.id
			          pass.pass_set_id = @pass_set.id
			          pass.redeemed = false
			          pass.entries=num_passes
		            pass.confirmation=SecureRandom.hex(4)
			          pass.save
			          UserMailer.purchase_confirmation(@user,pass).deliver
                redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
        		else
        		    redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured.'
		        end
		    end
		elsif params[:credit_card_save] == "1"
		  logger.error "Here in 1"
		  if @purchase.save_with_payment(current_user)
		      @pass_set.sold_passes+=num_passes
		      @pass_set.unsold_passes-=num_passes
		      @pass_set.save
		      # for i in 0..num_passes-1
			      pass = Pass.new
			      pass.name = params[:purchase][:name]
			      pass.purchase_id = @purchase.id
			      pass.pass_set_id = @pass_set.id
			      pass.redeemed = false
				  pass.entries=num_passes
				  pass.confirmation=SecureRandom.hex(4)
			      pass.save
		      #end
		UserMailer.purchase_confirmation(@user,pass).deliver
          redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
		  else
		      redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured.'
		  end
		else
          logger.error "Purchase: #{@purchase.inspect}"
		  logger.error "Here in nothing"
		  if @purchase.payment
		      @pass_set.sold_passes+=num_passes
		      @pass_set.unsold_passes-=num_passes
		      @pass_set.save
		      # for i in 0..num_passes-1
			      pass = Pass.new
			      pass.name = params[:purchase][:name]
			      pass.purchase_id = @purchase.id
			      pass.pass_set_id = @pass_set.id
			      pass.redeemed = false
				  pass.entries=num_passes
				  pass.confirmation=SecureRandom.hex(4)
			      pass.save
		      #end
		  UserMailer.purchase_confirmation(@user,pass).deliver
          redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
		  else
		      redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured.'
		  end
 		end   
	end


 
	  def purchase_history
  		@user = current_user
  		@bar = Bar.find(params[:purchase][:bar])
  		@pass_set = PassSet.find(params[:purchase][:pass_set])
  		num_passes = params[:purchase][:num_passes].to_i
  		if num_passes > @pass_set.unsold_passes
  			flash[:error] = 'Not enough passes left'
  			redirect_to [@bar,@pass_set]
  			return
  		end
  		@purchase = Purchase.new(params[:purchase])
  		@purchase.user_id = @user.id
  		@purchase.date = params[:purchase][:date]
  		@purchase.price = @purchase.integer_convert(@pass_set.price)

  		logger.error "Stripe error while creating customer: #{@user.stripe_customer_token}"
  		if @user.stripe_customer_token != nil
  		  if @purchase.payment_return_customer(current_user)
  		      @pass_set.sold_passes+=num_passes
  		      @pass_set.unsold_passes-=num_passes
  		      @pass_set.save
  		      # for i in 0..num_passes-1
  			      pass = Pass.new
  			      pass.name = params[:purchase][:name]
  			      pass.purchase_id = @purchase.id
  			      pass.pass_set_id = @pass_set.id
  			      pass.redeemed = false
  				  pass.entries=num_passes
  				  pass.confirmation=SecureRandom.hex(4)
  			      pass.save
  		      #end
  		  UserMailer.purchase_confirmation(@user,pass).deliver
            redirect_to [pass], notice: 'Purchase created'
  		    else
  		      redirect_to [@bar,@pass_set], notice: 'Purchase NOT Created'
  		    end
  		  end
  	  end

end
