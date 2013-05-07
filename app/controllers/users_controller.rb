class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_A? , :except => [:index, :update]
  
  def index
  end

  def show
      @user = User.find(params[:id])
		  @passes = @user.passes.includes(:pass_set).order('updated_at DESC').paginate(:page => params[:page], :per_page => 5)
	    logger.error "#{@bars.inspect}"
	    @bars = @user.bars
	    logger.error "#{@locations.inspect}"
	    @locations = @user.locations
	    @events = @user.events
  end
  
  def setPartner 
      @user = User.find(params[:id])
	    @user.partner=true
	    @user.save
	    redirect_to :controller=>'admin', :action=>'partners'
	    flash[:notice] = @user.name + " was set as a partner!"
  end
  
  def unsetPartner
      @user = User.find(params[:id])
	    @user.partner=false
	    @user.save
	    redirect_to :controller=>'admin', :action=>'customers'
		  flash[:notice] = @user.name + " was unset as a partner!"
  end

  def destroy
      @user = User.find(params[:id])
      @userTemp = @user
      @user.destroy
      if(@userTemp.partner?)
          respond_to do |format|
              format.html { redirect_to :controller=>'admin', :action=>'partners'}
              format.json { head :no_content }
	        end
      else
          respond_to do |format|
              format.html { redirect_to :controller=>'admin', :action=>'customers'}
              format.json { head :no_content }
	        end
      end
  end
  
  def update
      @user = User.new(params[:user])
      current_user.stripe_card_token = @user.stripe_card_token
      logger.error "Stripe error while creating customer: #{current_user.stripe_customer_token} and #{current_user.stripe_card_token}"
      if current_user.stripe_customer_token != nil
          current_user.save_token
          redirect_to :root, notice: 'Card Updated'
      else
          current_user.create_token
          redirect_to :root, notice: 'Card Added'
      end
  end
end