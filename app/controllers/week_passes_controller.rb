class WeekPassesController < ApplicationController
  # GET /week_passes/1
  # GET /week_passes/1.json
  def show
    @week_pass = WeekPass.find(params[:id])
    @bar = Bar.find(params[:bar_id])
	  @valid_passes = @week_pass.weekly_passes.order("name DESC").where('redeemed = ?', false).paginate(:page => params[:used_passes_page], :per_page => 5)
	  @invalid_passes = @week_pass.weekly_passes.order("name DESC").where('redeemed = ?', true).paginate(:page => params[:unused_passes_page], :per_page => 5)
	  logger.error "Valid: #{@valid_passes.inspect}"
	  logger.error "InValid: #{@invalid_passes.inspect}"
    @purchase = Purchase.new
    logger.error "#{@pass_set.inspect}"
    logger.error "#{current_user.inspect}"
    if current_user.stripe_customer_token != nil
      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
      if @customer_card.active_card != nil
          @last_four = @customer_card.active_card.last4
          @end_month = @customer_card.active_card.exp_month
          @end_year = @customer_card.active_card.exp_year
      end
    end
    @full_bar_path = "http://#{request.host}" + (bar_path @week_pass.bar).to_s
    @open_graph = false
    if flash[:notice] == 'Purchase created'
      @open_graph = true
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pass_set }
    end
  end

  # GET /week_passes/new
  # GET /week_passes/new.json
  def new
    @week_pass = WeekPass.new
	  @week_pass.week_total_sold = 0
	  @week_pass.week_total_unsold = @week_pass.week_total_released
    @bar = Bar.find(params[:bar_id])
    @bar_label = "Bar ID for "<<@bar.name
    @week_pass.bar = @bar

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @week_pass }
    end
  end

  # GET /week_passes/1/edit
  def edit
    @bar = Bar.find(params[:bar_id])
    @week_pass = WeekPass.find(params[:id])
  end

  # POST /week_passes
  # POST /week_passes.json
  def create
    @week_pass = WeekPass.new(params[:week_pass])
    @week_pass.week_total_sold = 0
    @week_pass.week_total_unsold = @week_pass.week_total_released
    @bar = Bar.find(params[:bar_id])
    @week_pass.bar = @bar
    @week_pass.revenue_total = 0.0

    respond_to do |format|
      if @week_pass.save
        format.html { redirect_to [@bar.user, @bar], notice: 'Week Pass was successfully created.' }
        format.json { render json: @week_pass, status: :created, location: @week_pass }
      else
        format.html { render action: "new" }
        format.json { render json: @week_pass.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /week_passes/1
  # PUT /week_passes/1.json
  def update
    @week_pass = WeekPass.find(params[:id])
    @bar = Bar.find(params[:bar_id])
    @week_pass.week_total_unsold = Integer(params[:week_pass]["week_total_released"]) - @week_pass.week_total_sold

    respond_to do |format|
      if @week_pass.update_attributes(params[:week_pass])
        format.html { redirect_to [@bar.user, @bar], notice: 'Week pass was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @week_pass.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /week_passes/1
  # DELETE /week_passes/1.json
  def destroy
    @week_pass = WeekPass.find(params[:id])
    @week_pass.destroy

    respond_to do |format|
      format.html { redirect_to week_passes_url }
      format.json { head :no_content }
    end
  end
  
  def close_set
      @week_pass = WeekPass.find(params[:week_pass_id])
      @bar = @week_pass.bar
      @week_pass.week_total_released = @week_pass.week_total_sold
      @week_pass.week_total_unsold = 0
      @week_pass.save
    
      respond_to do |format|
          if current_user.partner != true
              format.html { redirect_to [@bar], notice: 'Week set was successfully closed.' }
          else
              format.html { redirect_to [@bar, @week_pass], notice: 'Week set was successfully closed.' }
          end
          format.json { head :no_content }
      end
  end
end
