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
      @bar = Bar.find(params[:bar_id])
      @pass_set = PassSet.find(params[:id])
	    @used_passes = @pass_set.passes.order("name DESC").where('redeemed = ?', true).order('passes.reservation_time ASC').paginate(:page => params[:used_passes_page], :per_page => 5)
	    @unused_passes = @pass_set.passes.order("name DESC").where('redeemed = ?', false).order('passes.reservation_time ASC').paginate(:page => params[:unused_passes_page], :per_page => 5)
	    if @pass_set.reservation_time_periods == true && @pass_set.selling_passes == false
	        @available_times = @pass_set.time_periods.first
	        @reservations_times = Array.new
          time_columns = @available_times.attributes.values
          # Remove fields that aren't times
          3.times do
              time_columns.delete_at(time_columns.length-1)
          end
          time_columns.delete_at(0)
	        for x in 0..TimePeriod::TIME_LIST.length-1
	            if time_columns[x*2]
	                @reservations_times.push(TimePeriod::TIME_LIST[x].first)
	            end
	        end
	    end
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
      logger.error "Selling Passes: #{@existing_set.selling_passes}"
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
  				    format.html { redirect_to edit_user_location_pass_set_path(@location.user, @location, @pass_set) }
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
      @bar = Bar.find(params[:bar_id])
      @pass_set = PassSet.find(params[:id])
	    @date = Date.new(params[:pass_set]["date(1i)"].to_i,params[:pass_set]["date(2i)"].to_i,params[:pass_set]["date(3i)"].to_i)
	    @existing_set = @bar.pass_sets.where("date = ?", @date).first
      if @existing_set.nil?
          logger.error "Nil Existing Set"
          flash[:notice] = "Error: You cannot change the date of this pass set. Please create a new one"
          redirect_to :action => "index", :controller => "bars"
          return
      end
      if @pass_set.reservation_time_periods == false
	        @pass_set.unsold_passes = Integer(params[:pass_set]["total_released_passes"]) - @pass_set.sold_passes
	    end
      @existing_sets = @bar.pass_sets.where("date = ?", @date).length
        
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
	            if @pass_set.reservation_time_periods == true && @pass_set.selling_passes == false
	                @new_pass_num = 0
	                logger.error "Inside"
                  if @pass_set.time_periods.first.ten_am_available == true
                      @new_pass_num += @pass_set.time_periods.first.ten_am_tables                        
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.ten_thirty_am_available == true
                      @new_pass_num += @pass_set.time_periods.first.ten_thirty_am_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.eleven_am_available == true
                      @new_pass_num += @pass_set.time_periods.first.eleven_am_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.eleven_thirty_am_available == true
                      @new_pass_num += @pass_set.time_periods.first.eleven_thirty_am_tables
                      logger.error "Pass Total: #{@new_pass_num}"    
                  end
                  if @pass_set.time_periods.first.twelve_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.twelve_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.twelve_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.twelve_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.one_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.one_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.one_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.one_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.two_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.two_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.two_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.two_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.three_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.three_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.three_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.three_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.four_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.four_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}" 
                  end
                  if @pass_set.time_periods.first.four_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.four_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.five_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.five_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}" 
                  end
                  if @pass_set.time_periods.first.five_thirty_pm_available == true                        
                      @new_pass_num += @pass_set.time_periods.first.five_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.six_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.six_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}" 
                  end
                  if @pass_set.time_periods.first.six_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.six_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.seven_pm_available == true                        
                      @new_pass_num += @pass_set.time_periods.first.seven_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.seven_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.seven_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.eight_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.eight_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}" 
                  end
                  if @pass_set.time_periods.first.eight_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.eight_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.nine_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.nine_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}" 
                  end
                  if @pass_set.time_periods.first.nine_thirty_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.nine_thirty_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  if @pass_set.time_periods.first.ten_pm_available == true
                      @new_pass_num += @pass_set.time_periods.first.ten_pm_tables
                      logger.error "Pass Total: #{@new_pass_num}"
                  end
                  @pass_set.total_released_passes = @new_pass_num + @pass_set.sold_passes
                  @pass_set.unsold_passes = @pass_set.total_released_passes - @pass_set.sold_passes
      	          @pass_set.save
    	        end
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
  
  def close_set
      @pass_set = PassSet.find(params[:pass_set_id])
      @bar = @pass_set.bar
      @pass_set.total_released_passes = @pass_set.sold_passes
      @pass_set.unsold_passes = 0
      if @pass_set.reservation_time_periods == true
          @available_times = @pass_set.time_periods.first
          if @available_times.ten_am_available == true
              @available_times.ten_am_available = false
              @available_times.ten_am_tables = 0
          end
          if @available_times.ten_thirty_am_available == true
              @available_times.ten_thirty_am_available = false
              @available_times.ten_thirty_am_tables = 0
          end
          if @available_times.eleven_am_available == true
              @available_times.eleven_am_tables = 0
              @available_times.eleven_am_available = false
          end
          if @available_times.eleven_thirty_am_available == true
              @available_times.eleven_thirty_am_tables = 0
              @available_times.eleven_thirty_am_available = false
          end
          if @available_times.twelve_pm_available == true
              @available_times.twelve_pm_tables = 0
              @available_times.twelve_pm_available = false
          end
          if @available_times.twelve_thirty_pm_available == true
              @available_times.twelve_thirty_pm_tables = 0
              @available_times.twelve_thirty_pm_available = false
          end
          if @available_times.one_pm_available == true
              @available_times.one_pm_tables = 0
              @available_times.one_pm_available = false
          end
          if @available_times.one_thirty_pm_available == true                
            @available_times.one_thirty_pm_tables = 0
              @available_times.one_thirty_pm_available = false
          end
          if @available_times.two_pm_available == true
              @available_times.two_pm_tables = 0
              @available_times.two_pm_available = false
          end
          if @available_times.two_thirty_pm_available == true
              @available_times.two_thirty_pm_tables = 0
              @available_times.two_thirty_pm_available = false
          end
          if @available_times.three_pm_available == true
              @available_times.three_pm_tables = 0
              @available_times.three_pm_available = false
          end
          if @available_times.three_thirty_pm_available == true
              @available_times.three_thirty_pm_tables = 0
              @available_times.three_thirty_pm_available = false
          end
          if @available_times.four_pm_available == true
              @available_times.four_pm_tables = 0
              @available_times.four_pm_available = false
          end
          if @available_times.four_thirty_pm_available == true
              @available_times.four_thirty_pm_tables = 0 
              @available_times.four_thirty_pm_available = false
          end
          if @available_times.five_pm_available == true
              @available_times.five_pm_tables = 0
              @available_times.five_pm_available = false
          end
          if @available_times.five_thirty_pm_available == true
              @available_times.five_thirty_pm_tables = 0
              @available_times.five_thirty_pm_available = false
          end
          if @available_times.six_pm_available == true
              @available_times.six_pm_tables = 0
              @available_times.six_pm_available = false
          end
          if @available_times.six_thirty_pm_available == true
              @available_times.six_thirty_pm_tables = 0
              @available_times.six_thirty_pm_available = false
          end
          if @available_times.seven_pm_available == true
              @available_times.seven_pm_tables = 0
              @available_times.seven_pm_available = false
          end
          if @available_times.seven_thirty_pm_available == true                
              @available_times.seven_thirty_pm_tables = 0
              @available_times.seven_thirty_pm_available = false
          end
          if @available_times.eight_pm_available == true
              @available_times.eight_pm_tables = 0
              @available_times.eight_pm_available = false
          end
          if @available_times.eight_thirty_pm_available == true
              @available_times.eight_thirty_pm_tables = 0
              @available_times.eight_thirty_pm_available = false
          end
          if @available_times.nine_pm_available == true
              @available_times.nine_pm_tables = 0
              @available_times.nine_pm_available = false
          end
          if @available_times.nine_thirty_pm_available == true
              @available_times.nine_thirty_pm_tables = 0
              @available_times.nine_thirty_pm_available = false
          end
          if @available_times.ten_pm_available == true
              @available_times.ten_pm_tables = 0
              @available_times.ten_pm_available = false
          end
          @available_times.save
      end
      @pass_set.save
    
      respond_to do |format|
          format.html { redirect_to [@bar], notice: 'Pass set was successfully closed.' }
          format.json { head :no_content }
      end
  end
end