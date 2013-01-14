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
		elsif params[:credit_card_save] == "1"
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
          redirect_to [pass], notice: 'Purchase created'
		  else
		      redirect_to [@bar,@pass_set], notice: 'Purchase NOT Created'
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
		      #end
		  UserMailer.purchase_confirmation(@user,pass).deliver
          redirect_to [pass], notice: 'Purchase created'
		  else
		      redirect_to [@bar,@pass_set], notice: 'Purchase NOT Created'
		  end
 		end   
	  end
end