class PassesController < ApplicationController

  before_filter :authenticate_user!
  
  def index
  	@user = current_user
    # Eager loading pass sets on the user's passes
  	@valid_passes = @user.passes.includes(:pass_set).where('date >= ?', Time.now.to_date).order('updated_at DESC').paginate(:page => params[:page], :per_page => 5)
  	@past_passes = @user.passes.includes(:pass_set).where('date < ?', Time.now.to_date).order('updated_at DESC').paginate(:page => params[:page], :per_page => 5)
  end
  
  def show
		@user=current_user
		@pass = Pass.find(params[:id])
		logger.error "Purchase #: #{@pass.purchase}"
		logger.error "User #: #{@pass.purchase.user}"
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
