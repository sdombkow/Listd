class PassSetsController < ApplicationController
  # GET /pass_sets
  # GET /pass_sets.json
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsPassSet, :only => [:edit,:update,:new,:delete,:create]

  # Ensure that the user owns the bar for this pass set
  def ownsPassSet
    @bar = Bar.find(params[:bar_id])
    if current_user.partner? == false and current_user.admin? == false
        redirect_to @bar
    elsif current_user.partner? == true and @bar.user_id != current_user.id
        redirect_to @bar
    end
    return
  end

  def index
  @passes = Pass.where("pass_set_id = ? and created_at > ?", params[:pass_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /pass_sets/1
  # GET /pass_sets/1.json
  def show
    @bar = Bar.find(params[:bar_id])
    @pass_set = PassSet.find(params[:id])
	  @used_passes = @pass_set.passes.order("name DESC").where('redeemed == ?', true).paginate(:page => params[:used_passes_page], :per_page => 5)
	  @unused_passes = @pass_set.passes.order("name DESC").where('redeemed == ?', false).paginate(:page => params[:unused_passes_page], :per_page => 5)
    @purchase = Purchase.new
    if current_user.stripe_customer_token != nil
      @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
      if @customer_card.active_card != nil
          @last_four = @customer_card.active_card.last4
          @end_month = @customer_card.active_card.exp_month
          @end_year = @customer_card.active_card.exp_year
      end
    end
    @full_bar_path = "http://#{request.host}" + (bar_path @pass_set.bar).to_s
    @open_graph = false
    if flash[:notice] == 'Purchase created'
      @open_graph = true
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pass_set }
    end
  end

  # GET /pass_sets/new
  # GET /pass_sets/new.json
  def new
    @pass_set = PassSet.new
	@pass_set.sold_passes = 0
	@pass_set.unsold_passes = @pass_set.total_released_passes
    @bar = Bar.find(params[:bar_id])
    @bar_label = "Bar ID for "<<@bar.name
    @pass_set.bar = @bar
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pass_set }
    end
  end

  # GET /pass_sets/1/edit
  def edit
    @bar = Bar.find(params[:bar_id])
    @pass_set = PassSet.find(params[:id])
  end

  # POST /pass_sets
  # POST /pass_sets.json
  def create
    @pass_set = PassSet.new(params[:pass_set])
	  @pass_set.sold_passes = 0
	  @pass_set.unsold_passes = @pass_set.total_released_passes
    @bar = Bar.find(params[:bar_id])
    @pass_set.bar = @bar
	  @existing_set = @bar.pass_sets.where("date = ?", @pass_set.date).first
    respond_to do |format|
		if @pass_set.date < Date.today
		flash[:notice] = 'Error: You are trying to create a pass for a date that has already passed!'
        format.html { render action: "new"  }
        format.json { render json: @pass_set.errors, status: :unprocessable_entity }
	elsif @existing_set
				flash[:notice] = 'Error: Please use edit to change existing passes'
				format.html { redirect_to edit_user_bar_pass_set_path(@bar.user, @bar, @existing_set) }
				format.json { render json: @pass_set.errors, status: :unprocessable_entity }
      elsif @pass_set.save
        format.html { redirect_to [@bar.user, @bar], notice: 'Pass set was successfully created.' }
        format.json { render json: @pass_set, status: :created, location: @pass_set }
      else
        format.html { render action: "new" }
        format.json { render json: @pass_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pass_sets/1
  # PUT /pass_sets/1.json
  def update
    @bar = Bar.find(params[:bar_id])
    @pass_set = PassSet.find(params[:id])
	  @date = Date.new(params[:pass_set]["date(1i)"].to_i,params[:pass_set]["date(2i)"].to_i,params[:pass_set]["date(3i)"].to_i)
	  @existing_set = @bar.pass_sets.where("date = ?", @date).first
	  @existing_set.unsold_passes = Integer(params[:pass_set]["total_released_passes"]) - @existing_set.sold_passes
	  @existing_set.save
	  logger.error "Total: #{params[:pass_set]["total_released_passes"]}"
	  logger.error "Unsold: #{@existing_set.unsold_passes}"
	  logger.error "Sold: #{@existing_set.sold_passes}"
    respond_to do |format|
	if @date < Date.today
		flash[:notice] = 'Error: You are trying to edit a pass to a date that has already passed!'
	    format.html { render action: "edit" }
        format.json { render json: @pass_set.errors, status: :unprocessable_entity }
	elsif @existing_set
		    @existing_set.update_attributes(params[:pass_set])
	      format.html { redirect_to [@bar.user, @bar], notice: 'Pass set was successfully updated.' }
        format.json { head :no_content }
	elsif @pass_set.update_attributes(params[:pass_set])
        format.html { redirect_to [@bar.user, @bar], notice: 'Pass set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pass_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pass_sets/1
  # DELETE /pass_sets/1.json
  def destroy
  @pass_set = PassSet.find(params[:id])
  @bar = @pass_set.bar
  @pass_set.destroy

    respond_to do |format|
      format.html { redirect_to [@bar], notice: 'Pass set was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
