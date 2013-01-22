class PassesController < ApplicationController

  before_filter :authenticate_user!
  
  def index
  	@user = current_user
    # Eager loading pass sets on the user's passes
  	@passes = @user.passes.includes(:pass_set).order('updated_at DESC')
  end
  
  def show
		@user=current_user
		@pass = Pass.find(params[:id])
		if(@user != @pass.purchase.user)
		 if(!@user.partner?)
		redirect_to:root
		flash[:notice] = "Opps! You went somewhere you're not supposed to."
		end
		end
  end
  
  def toggleRedeem
   @pass = Pass.find(params[:id])
   if(@pass.redeemed?)
   @pass.redeemed=false
   else
   @pass.redeemed=true
   end
   @pass.save
   redirect_to :back
   flash[:notice] = "Redeem Toggled!"
  end
end
