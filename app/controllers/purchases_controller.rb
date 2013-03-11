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
		@purchase.price = (String(@pass_set.price).split(".").first+@decimals)
		@purchase.price = Integer(@purchase.price)*num_passes
		logger.error "Price: #{@purchase.price}"
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
		            @pass_set.revenue_total = @pass_set.price + @pass_set.revenue_total
		            @pass_set.save
		            # for i in 0..num_passes-1
			          pass = Pass.new
			          pass.name = params[:purchase][:name]
			          pass.purchase_id = @purchase.id
			          pass.pass_set_id = @pass_set.id
			          pass.redeemed = false
			          pass.price = @pass_set.price
			          if @pass_set.reservation_time_periods == true
			            pass.reservation_time = params[:purchase][:reservation_time]
			          end
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
	                else
	                    @pass_set.sold_passes+=1
	                    @pass_set.unsold_passes-=1
	                end
	            end
	            @pass_set.revenue_total = @pass_set.price + @pass_set.revenue_total
    		      @pass_set.save
    			    pass = Pass.new
    			    pass.name = params[:purchase][:name]
    			    pass.purchase_id = @purchase.id
    			    pass.pass_set_id = @pass_set.id
    			    pass.redeemed = false
    			    pass.price = @pass_set.price
    			    if @pass_set.reservation_time_periods == true
		            pass.reservation_time = params[:purchase][:reservation_time]
		          end
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
		                else
		                    @pass_set.sold_passes+=1
		                    @pass_set.unsold_passes-=1
		                end
		            end
		            @pass_set.revenue_total = @pass_set.price + @pass_set.revenue_total
		            @pass_set.save
		            # for i in 0..num_passes-1
			          pass = Pass.new
			          pass.name = params[:purchase][:name]
			          pass.purchase_id = @purchase.id
			          pass.pass_set_id = @pass_set.id
			          pass.redeemed = false
			          pass.price = @pass_set.price
			          if @pass_set.reservation_time_periods == true
			            pass.reservation_time = params[:purchase][:reservation_time]
			          end
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
              else
                  @pass_set.sold_passes+=1
                  @pass_set.unsold_passes-=1
              end
          end
          @pass_set.revenue_total = @pass_set.price + @pass_set.revenue_total
		      @pass_set.save
		      # for i in 0..num_passes-1
			      pass = Pass.new
			      pass.name = params[:purchase][:name]
			      pass.purchase_id = @purchase.id
			      pass.pass_set_id = @pass_set.id
			      pass.redeemed = false
			      pass.price = @pass_set.price
			      if @pass_set.reservation_time_periods == true
	            pass.reservation_time = params[:purchase][:reservation_time]
	          end
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
              else
                  @pass_set.sold_passes+=1
                  @pass_set.unsold_passes-=1
              end
          end
          @pass_set.revenue_total = @pass_set.price + @pass_set.revenue_total
		      @pass_set.save
		      # for i in 0..num_passes-1
			      pass = Pass.new
			      pass.name = params[:purchase][:name]
			      pass.purchase_id = @purchase.id
			      pass.pass_set_id = @pass_set.id
			      pass.redeemed = false
			      pass.price = @pass_set.price
			      if @pass_set.reservation_time_periods == true
	            pass.reservation_time = params[:purchase][:reservation_time]
	          end
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
