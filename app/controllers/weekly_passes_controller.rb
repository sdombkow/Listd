class WeeklyPassesController < ApplicationController
  # GET /weekly_passes
  # GET /weekly_passes.json
  def index
    @weekly_passes = WeeklyPass.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @weekly_passes }
    end
  end

  # GET /weekly_passes/1
  # GET /weekly_passes/1.json
  def show
    @user=current_user
		@pass = WeeklyPass.find(params[:id])
		if @pass.purchase.stripe_charge_token != nil
		  @customer_card = Stripe::Charge.retrieve(@pass.purchase.stripe_charge_token)
      @card_type = @customer_card.card.type
      @card_four = @customer_card.card.last4
    end
		logger.error "Purchase #: #{@pass.purchase}"
		logger.error "Pass User #: #{@pass.purchase.user}"
		logger.error "Real User #: #{@user}"
		if(@user != @pass.purchase.user)
		  if(!@user.partner? && !@user.admin?)
		    redirect_to:root
		    flash[:notice] = "Opps! You went somewhere you're not supposed to."
		  end
		end
		respond_to do |format|
      format.html
      format.pdf do
          render :pdf => "show.pdf.prawn"
      end
    end
  end

  # GET /weekly_passes/new
  # GET /weekly_passes/new.json
  def new
    @weekly_pass = WeeklyPass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @weekly_pass }
    end
  end

  # GET /weekly_passes/1/edit
  def edit
    @weekly_pass = WeeklyPass.find(params[:id])
  end

  # POST /weekly_passes
  # POST /weekly_passes.json
  def create
    @weekly_pass = WeeklyPass.new(params[:weekly_pass])

    respond_to do |format|
      if @weekly_pass.save
        format.html { redirect_to @weekly_pass, notice: 'Weekly pass was successfully created.' }
        format.json { render json: @weekly_pass, status: :created, location: @weekly_pass }
      else
        format.html { render action: "new" }
        format.json { render json: @weekly_pass.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /weekly_passes/1
  # PUT /weekly_passes/1.json
  def update
    @weekly_pass = WeeklyPass.find(params[:id])

    respond_to do |format|
      if @weekly_pass.update_attributes(params[:weekly_pass])
        format.html { redirect_to @weekly_pass, notice: 'Weekly pass was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @weekly_pass.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_passes/1
  # DELETE /weekly_passes/1.json
  def destroy
    @weekly_pass = WeeklyPass.find(params[:id])
    @weekly_pass.destroy

    respond_to do |format|
      format.html { redirect_to weekly_passes_url }
      format.json { head :no_content }
    end
  end
end
