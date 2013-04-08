class PurchasesController < ApplicationController
	
	def create
		  @user = current_user
		  @bar = Bar.find(params[:purchase][:bar])
		  @pass_set = PassSet.find(params[:purchase][:pass_set])
		  num_passes = params[:purchase][:num_passes].to_i
	    
	    if num_passes > @pass_set.unsold_passes && @pass_set.selling_passes == true
			    flash[:error] = 'Not enough passes left'
			    redirect_to [@bar,@pass_set]
			    return
		  end
		
		  if @pass_set.unsold_passes == 0
		      flash[:error] = 'Not enough passes left'
			    redirect_to [@bar,@pass_set]
			    return
		  end
		  
		  friend_names = params[:purchase][:friend_names]
      friend_emails = params[:purchase][:friend_emails]
      params[:purchase].delete("friend_names")
      params[:purchase].delete("friend_emails")
      
		  @purchase = Purchase.new(params[:purchase])
		  @purchase.user_id = @user.id
		  @purchase.date = params[:purchase][:date]	  
		  if String(@pass_set.price).split(".").last.length == 1
	        @decimals = String(@pass_set.price).split(".").last + "0"
	    else 
	        @decimals = String(@pass_set.price).split(".").last
	    end
	    @purchase.price = (String(@pass_set.price).split(".").first + @decimals)
		  @purchase.price = Integer(@purchase.price)*num_passes
		  
		  if @user.stripe_customer_token != nil
		      if @purchase.stripe_card_token == ""
		          if @purchase.payment_return_customer(current_user)
        		      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
        		      if @customer_card.active_card != nil
                      @end_month = @customer_card.active_card.exp_month
                      @end_year = @customer_card.active_card.exp_year
                  end
		              if @end_month < Time.now.month && @end_year < Time.now.year
		                  cu = Stripe::Customer.retrieve(current_user.stripe_customer_token)
                      cu.delete
                      current_user.update_attribute(:stripe_customer_token,nil)
                      current_user.save!
    		              redirect_to [@bar,@pass_set], notice: 'Sorry, your transaction has not occured. Your previous saved card has expired and is no longer valid.'
    				          return
    			        end
              else
              		redirect_to [@bar,@pass_set], notice: current_user.error_message
              		return
            	end
          elsif params[:credit_card_save] == "1"
    			    if @purchase.return_customer_save_payment(current_user)
    			    else
        		      redirect_to [@bar,@pass_set], notice: current_user.error_message
        		      return
        		  end
    			else
    		      if @purchase.payment(current_user)
    		      else
          		    redirect_to [@bar,@pass_set], notice: current_user.error_message
          		    return
  		        end
  		    end    
    	elsif params[:credit_card_save] == "1"	
    	    if @purchase.save_with_payment(current_user)
    	    else
    		      redirect_to [@bar,@pass_set], notice: current_user.error_message
    		      return
    		  end
    	else
          logger.error "Purchase: #{@purchase.inspect}"
    		  if @purchase.payment(current_user)
    			else
     		      redirect_to [@bar,@pass_set], notice: current_user.error_message
     		      return
     		  end
      end   
    			    
    	if @pass_set.selling_passes == true
          @pass_set.sold_passes+=num_passes
          @pass_set.unsold_passes-=num_passes
      else
          if @pass_set.reservation_time_periods == true
              @table_times = @pass_set.time_periods.first
              if params[:purchase][:reservation_time] == "10:00 AM"
                  @table_times.ten_am_tables -= 1
                  if @table_times.ten_am_tables == 0
                      @table_times.ten_am_available = false
                  end
              elsif params[:purchase][:reservation_time] == "10:30 AM"
		              @table_times.ten_thirty_am_tables -= 1
		              if @table_times.ten_thirty_am_tables == 0
                      @table_times.ten_thrity_am_available = false
                  end
		          elsif params[:purchase][:reservation_time] == "11:00 AM"
  		            @table_times.eleven_am_tables -= 1
  		            if @table_times.eleven_am_tables == 0
                      @table_times.eleven_am_available = false
                  end
  		        elsif params[:purchase][:reservation_time] == "11:30 AM"
    		          @table_times.eleven_thirty_am_tables -= 1
    		          if @table_times.eleven_thirty_am_tables == 0
                      @table_times.eleven_thirty_am_available = false
                  end
    		      elsif params[:purchase][:reservation_time] == "12:00 PM"
      		        @table_times.twelve_pm_tables -= 1
      		        if @table_times.twelve_pm_tables == 0
                      @table_times.twelve_pm_available = false
                  end
      		    elsif params[:purchase][:reservation_time] == "12:30 PM"
        		      @table_times.twelve_thirty_pm_tables -= 1
        		      if @table_times.twelve_thirty_pm_tables == 0
                      @table_times.twelve_thirty_pm_available = false
                  end
        		  elsif params[:purchase][:reservation_time] == "1:00 PM"
          		    @table_times.one_pm_tables -= 1
          		    if @table_times.one_pm_tables == 0
                      @table_times.one_pm_available = false
                  end
          		elsif params[:purchase][:reservation_time] == "1:30 PM"
                  @table_times.one_thirty_pm_tables -= 1
    		          if @table_times.one_thirty_pm_tables == 0
                      @table_times.one_thirty_pm_available = false
                  end
            	elsif params[:purchase][:reservation_time] == "2:00 PM"
              		@table_times.two_pm_tables -= 1
                  if @table_times.two_pm_tables == 0
                      @table_times.two_pm_available = false
                  end
              elsif params[:purchase][:reservation_time] == "2:30 PM"
            	    @table_times.two_thirty_pm_tables -= 1
        	        if @table_times.two_thirty_pm_tables == 0
                      @table_times.two_thirty_pm_available = false            
                  end
              elsif params[:purchase][:reservation_time] == "3:00 PM"
                  @table_times.three_pm_tables -= 1
      		        if @table_times.three_pm_tables == 0
                      @table_times.three_pm_available = false
                  end            	      
              elsif params[:purchase][:reservation_time] == "3:30 PM"
                  @table_times.three_thirty_pm_tables -= 1
                  if @table_times.three_thirty_pm_tables == 0
                      @table_times.three_thirty_pm_available = false
                  end
        		  elsif params[:purchase][:reservation_time] == "4:00 PM"
                  @table_times.four_pm_tables -= 1
                  if @table_times.four_pm_tables == 0
                      @table_times.four_pm_available = false          
                  end
          		elsif params[:purchase][:reservation_time] == "4:30 PM"
          	      @table_times.four_thirty_pm_tables -= 1
        		      if @table_times.four_thirty_pm_tables == 0
                      @table_times.four_thirty_pm_available = false
                  end
            	elsif params[:purchase][:reservation_time] == "5:00 PM"
                  @table_times.five_pm_tables -= 1
                  if @table_times.five_pm_tables == 0
                      @table_times.five_pm_available = false
                  end
              elsif params[:purchase][:reservation_time] == "5:30 PM"
          	      @table_times.five_thirty_pm_tables -= 1
        		      if @table_times.five_thirty_pm_tables == 0
                        @table_times.five_thirty_pm_available = false
                  end
              elsif params[:purchase][:reservation_time] == "6:00 PM"
                  @table_times.six_pm_tables -= 1
                  if @table_times.six_pm_tables == 0
                      @table_times.six_pm_available = false
                  end
          	  elsif params[:purchase][:reservation_time] == "6:30 PM"
              	  @table_times.six_thirty_pm_tables -= 1
            	    if @table_times.six_thirty_pm_tables == 0
                      @table_times.six_thirty_pm_available = false
                  end              		  
              elsif params[:purchase][:reservation_time] == "7:00 PM"
                  @table_times.seven_pm_tables -= 1
                  if @table_times.seven_pm_tables == 0
                      @table_times.seven_pm_available = false
                  end
          	  elsif params[:purchase][:reservation_time] == "7:30 PM"
            		  @table_times.seven_thirty_pm_tables -= 1
            		  if @table_times.seven_thirty_pm_tables == 0
                      @table_times.seven_thirty_pm_available = false
                  end
              elsif params[:purchase][:reservation_time] == "8:00 PM"
                  @table_times.eight_pm_tables -= 1
                  if @table_times.eight_pm_tables == 0
                      @table_times.eight_pm_available = false           
              end
              elsif params[:purchase][:reservation_time] == "8:30 PM"
          	      @table_times.eight_thirty_pm_tables -= 1
        		      if @table_times.eight_thirty_pm_tables == 0
                      @table_times.eight_thirty_pm_available = false
                  end
            	elsif params[:purchase][:reservation_time] == "9:00 PM"
                  @table_times.nine_pm_tables -= 1
                  if @table_times.nine_pm_tables == 0
                      @table_times.nine_pm_available = false
                  end
              elsif params[:purchase][:reservation_time] == "9:30 PM"
          	      @table_times.nine_thirty_pm_tables -= 1
        		      if @table_times.nine_thirty_pm_tables == 0
                      @table_times.nine_thirty_pm_available = false           
                  end
              elsif params[:purchase][:reservation_time] == "10:00 PM"
                  @table_times.ten_pm_tables -= 1
                  if @table_times.ten_pm_tables == 0
                      @table_times.ten_pm_available = false
                  end
              end
              @table_times.save
              @pass_set.sold_passes+=1
              @pass_set.unsold_passes-=1
          else
              @pass_set.sold_passes+=1
              @pass_set.unsold_passes-=1
          end
      end
    			    
    	@pass_set.revenue_total = @purchase.price + @pass_set.revenue_total
	    @pass_set.save 
	    
	    # for i in 0..num_passes-1
		  pass = Pass.new
		  pass.name = params[:purchase][:name]
		  pass.purchase_id = @purchase.id
		  pass.pass_set_id = @pass_set.id
		  pass.redeemed = false
		  pass.price = @pass_set.price
		  pass.total_price = @pass_set.price * num_passes
		  logger.error "#{@pass_set.price}"
		  logger.error "#{pass.price}"
		  logger.error "#{pass.total_price}"
		  if @pass_set.reservation_time_periods == true
		      pass.reservation_time = params[:purchase][:reservation_time]
		  end
			pass.entries = num_passes
			pass.confirmation = SecureRandom.hex(4)
		  pass.save
		  UserMailer.purchase_confirmation(@user,pass).deliver
      counter = 0
      while friend_names.nil? == false and counter < friend_names.length
          fn = friend_names[counter]
          fe = friend_emails[counter]
          pf = PassFriend.new
          pf.name = fn
          pf.email = fe
          pf.pass_id = pass.id
          pf.save
          UserMailer.friend_confirmation(fn,fe,pass).deliver
          counter += 1
      end
      redirect_to [pass], notice: "Thank you for your purchase, you will receive a confirmation email at #{@user.email}."
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