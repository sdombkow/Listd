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
		logger.error "Stripe Card Token: #{@purchase.stripe_card_token}"
		logger.error "Stripe customer: #{@user.stripe_customer_token}"
		if @user.stripe_customer_token != nil
		    logger.error "Here in not nil"
		    logger.error "Stripe Card Token: #{@user.stripe_card_token}"
		    @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
		    if @customer_card.active_card != nil
          @end_month = @customer_card.active_card.exp_month
          @end_year = @customer_card.active_card.exp_year
        end
        logger.error "#{@end_month < Time.now.month}"
        logger.error "#{@end_year < Time.now.year}"
		    logger.error "#{@end_month < Time.now.month || @end_year < Time.now.year}"
		    if @purchase.stripe_card_token == ""
		        logger.error "Here in Stipe Card Token Not Nil"
		        if @end_month < Time.now.month || @end_year < Time.now.year
		            cu = Stripe::Customer.retrieve(current_user.stripe_customer_token)
                cu.delete
    		        redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured. Your current saved card has expired and is no longer valid.'
    		        logger.error "Something is wrong here"
    				    return
    			  end
    			  logger.error "Here in 0 right before"
		        if @purchase.payment_return_customer(current_user)
		            logger.error "Here in 0"
		            if @pass_set.selling_passes == true
		                @pass_set.sold_passes+=num_passes
		                @pass_set.unsold_passes-=num_passes
		            else
		                @pass_set.sold_passes+=1
		                @pass_set.unsold_passes-=1
		            end 
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
    		  if @purchase.return_customer_save_payment(current_user)
    		      if @pass_set.selling_passes == true
	                @pass_set.sold_passes+=num_passes
	                @pass_set.unsold_passes-=num_passes
	            else
	                @pass_set.sold_passes+=1
	                @pass_set.unsold_passes-=1
	            end
    		      @pass_set.save
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
		    else
		        if @purchase.payment
		            logger.error "Here in 2"
		            if @pass_set.selling_passes == true
		                @pass_set.sold_passes+=num_passes
		                @pass_set.unsold_passes-=num_passes
		            else
		                @pass_set.sold_passes+=1
		                @pass_set.unsold_passes-=1
		            end
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
		      if @pass_set.selling_passes == true
              @pass_set.sold_passes+=num_passes
              @pass_set.unsold_passes-=num_passes
          else
              @pass_set.sold_passes+=1
              @pass_set.unsold_passes-=1
          end
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
		      if @pass_set.selling_passes == true
              @pass_set.sold_passes+=num_passes
              @pass_set.unsold_passes-=num_passes
          else
              @pass_set.sold_passes+=1
              @pass_set.unsold_passes-=1
          end
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
  		      if @pass_set.selling_passes == true
                @pass_set.sold_passes+=num_passes
                @pass_set.unsold_passes-=num_passes
            else
                @pass_set.sold_passes+=1
                @pass_set.unsold_passes-=1
            end
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
