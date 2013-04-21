class PassSetsController < ApplicationController  
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsPassSet, :only => [:edit,:update,:new,:delete,:create]

  # Ensure that the user owns the bar for this pass set
  def ownsPassSet
      @location = Location.find(params[:location_id])
      if current_user.partner? == false and current_user.admin? == false
          redirect_to @location
      elsif current_user.partner? == true and @bar.user_id != current_user.id
          redirect_to @location
      end
      return
  end

  # GET /pass_sets
  # GET /pass_sets.json
  def index
      @passes = Pass.where("pass_set_id = ? and created_at > ?", params[:pass_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /pass_sets/1
  # GET /pass_sets/1.json
  def show
      @location = Location.find(params[:location_id])
      @pass_set = PassSet.find(params[:id])
	    @used_passes = @pass_set.passes.order("name DESC").where('redeemed = ?', true).paginate(:page => params[:used_passes_page], :per_page => 5)
	    @unused_passes = @pass_set.passes.order("name DESC").where('redeemed = ?', false).paginate(:page => params[:unused_passes_page], :per_page => 5)
      @purchase = Purchase.new
      if current_user.stripe_customer_token != nil
          @customer_card = Stripe::Customer.retrieve(current_user.stripe_customer_token)
          if @customer_card.active_card != nil
              @last_four = @customer_card.active_card.last4
              @end_month = @customer_card.active_card.exp_month
              @end_year = @customer_card.active_card.exp_year
          end
      end
      @full_bar_path = "http://#{request.host}" + (location_path @pass_set.location).to_s
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
      @pass_set.build_fecha
      @pass_set.build_price_point
      @location = Location.find(params[:location_id])
      @location_label = "Location ID for "<< @location.name
    
      respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @pass_set }
      end
  end

  # GET /pass_sets/1/edit
  def edit
      @location = Location.find(params[:location_id])
      @pass_set = PassSet.find(params[:id])
  end

  # POST /pass_sets
  # POST /pass_sets.json
  def create
      @pass_set = PassSet.new(params[:pass_set])
      @fecha = Fecha.new(params[:pass_set][:fecha_attributes])
      @price_point = PricePoint.new(params[:pass_set][:price_point_attributes])
      logger.error "Ticket Set Values: #{@pass_set.inspect}"
      logger.error "Fecha Values: #{@fecha.inspect}"
      logger.error "Price Point Values: #{@price_point.inspect}"
      no_change = false
      existing = false
      @location_fechas = @location.fechas.where("date = ?", @fecha.date)
      @existing_set = @location_fechas.first
      logger.error "No Change: #{no_change}"
      logger.error "Fechas: #{@location_fechas.empty?}"
      logger.error "Fechas: #{@existing_set.inspect}"
      if @location_fechas.empty?
          @fecha.location = @location
          @fecha.pass_set = @pass_set
          @fecha.selling_passes = true
          @pass_set.sold_passes = 0
      	  @pass_set.unsold_passes = @pass_set.total_released_passes
      	  @pass_set.revenue_percentage = 0.7
      	  @pass_set.revenue_total = 0
      	  @pass_set.location = @location
      	  @pass_set.fecha = @fecha
      	  @price_point.num_released = @pass_set.total_released_passes
      	  @price_point.num_sold = 0
      	  @price_point.num_unsold = 0
      elsif @existing_set.selling_passes == false
          logger.error "In Existing Set"
          @fecha = @existing_set
          @fecha.pass_set = @pass_set
          @fecha.selling_passes = true
          @pass_set.sold_passes = 0
      	  @pass_set.unsold_passes = @pass_set.total_released_passes
      	  @pass_set.revenue_percentage = 0.7
      	  @pass_set.revenue_total = 0
      	  @pass_set.location = @location
      	  @pass_set.fecha = @fecha
      	  @price_point.num_released = @pass_set.total_released_passes
      	  @price_point.num_sold = 0
      	  @price_point.num_unsold = 0
      else       
          no_change = true
      end  

      respond_to do |format|
          if @fecha.date < Date.today
  	          flash[:notice] = 'Error: You are trying to create a pass set for a date that has already passed!'
              format.html { render action: "new"  }
              format.json { render json: @pass_set.errors, status: :unprocessable_entity }
          elsif no_change == true
              logger.error "Here"
  				    flash[:notice] = 'Error: Please use edit to change existing passes'
  				    format.html { redirect_to edit_user_location_pass_set_path(@location.user, @location, @existing_set.pass_set) }
  				    format.json { render json: @pass_set.errors, status: :unprocessable_entity }
          elsif @pass_set.save
              @fecha.pass_set = @pass_set
              @fecha.save!
              logger.error "Fecha Values: #{@fecha.inspect}"
              @price_point.pass_set_id = @pass_set.id
              @price_point.save!
              logger.error "Ticket Set Associated with Price Point #{@price_point.pass_set.inspect}"
              format.html { redirect_to [@location.user, @location], notice: 'Pass set was successfully created.' }
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
      @location = Location.find(params[:location_id])
      @pass_set = PassSet.find(params[:id])
	    @date = Date.new(params[:pass_set][:fecha_attributes]["date(1i)"].to_i,params[:pass_set][:fecha_attributes]["date(2i)"].to_i,params[:pass_set][:fecha_attributes]["date(3i)"].to_i)
	    @existing_set = @location.fechas.where("date = ?", @date).first.pass_set
	    logger.error "Ticket Set: #{@existing_set.inspect}"
      if @existing_set.nil?
          logger.error "Nil Existing Set"
          flash[:notice] = "Error: You cannot change the date of this pass set. Please create a new one"
          redirect_to :action => "index", :controller => "locations"
          return
      end
      @pass_set.unsold_passes = Integer(params[:pass_set]["total_released_passes"]) - @pass_set.sold_passes
      @existing_sets = @location.fechas.where("date = ? and selling_passes = ?", @date, true).length
      logger.error "Price: #{params[:pass_set][:price_point_attributes]}"
      @pass_set.price_point.price = params[:pass_set][:price_point_attributes]["price"]
      logger.error "Pass Set Price: #{@pass_set.price_point.price}"
      logger.error "Pass Set: #{@pass_set.inspect}"

      respond_to do |format|
          if @date < Date.today
  	          flash[:notice] = 'Error: You are trying to edit a pass to a date that has already passed!'
              format.html { render action: "edit" }
              format.json { render json: @pass_set.errors, status: :unprocessable_entity }
              # Next if statements prevents any editing to this pass set
          elsif @existing_sets == 1 and @existing_set.id != @pass_set.id
    	        flash[:notice] = 'Error: There is already a pass set with this date!'
              format.html { render action: "edit" }
              format.json { render json: @pass_set.errors, status: :unprocessable_entity }
          elsif @pass_set.update_attributes(params[:pass_set])
              format.html { redirect_to [@location.user, @location], notice: 'Pass set was successfully updated.' }
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
      @location = @pass_set.location
      @pass_set.destroy

      respond_to do |format|
        format.html { redirect_to [@location], notice: 'Pass set was successfully deleted.' }
        format.json { head :no_content }
      end
  end
  
  def close_set
      @pass_set = PassSet.find(params[:pass_set_id])
      @location = @pass_set.location
      @pass_set.total_released_passes = @pass_set.sold_passes
      @pass_set.unsold_passes = 0
      @pass_set.save
    
      respond_to do |format|
          format.html { redirect_to [@location], notice: 'Pass set was successfully closed.' }
          format.json { head :no_content }
      end
  end
end