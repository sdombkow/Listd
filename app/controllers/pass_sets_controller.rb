class PassSetsController < ApplicationController  
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsPassSet, :only => [:edit,:update,:new,:delete,:create]

  # Ensure that the user owns the bar for this pass set
  def ownsPassSet
      if params[:location_id] != nil
          @location = Location.find(params[:location_id])
          if current_user.partner? == false and current_user.admin? == false
              redirect_to @location
          elsif current_user.partner? == true and @location.user_id != current_user.id
              redirect_to @location
          end
          return
      elsif params[:event_id] != nil
          @event = Event.find(params[:event_id])
          if current_user.partner? == false and current_user.admin? == false
              redirect_to @event
          elsif current_user.partner? == true and @event.user_id != current_user.id
              redirect_to @event
          end
          return
      end
  end

  # GET /pass_sets
  # GET /pass_sets.json
  def index
      @passes = Pass.where("pass_set_id = ? and created_at > ?", params[:pass_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /pass_sets/1
  # GET /pass_sets/1.json
  def show
      if params[:location_id] != nil
          @location = Location.find(params[:location_id])
          @pass_set = PassSet.find(params[:id])
          @full_bar_path = "http://#{request.host}" + (location_path @pass_set.location).to_s
      elsif params[:event_id] != nil
          @event = Event.find(params[:event_id])
          @pass_set = PassSet.find(params[:id])
          @full_bar_path = "http://#{request.host}" + (event_path @pass_set.event).to_s
      end
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
      1.times { @pass_set.price_points.build }
      if params[:location_id] != nil
          @location = Location.find(params[:location_id])
          @location_label = "Location ID for "<< @location.name
      elsif params[:event_id] != nil
          @location = Event.find(params[:event_id])
          @location_label = "Event ID for "<< @event.name
      end
    
      respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @pass_set }
      end
  end

  # GET /pass_sets/1/edit
  def edit
      if params[:location_id] != nil
          @location = Location.find(params[:location_id])
      elsif params[:event_id] != nil
          @event = Event.find(params[:event_id])
      end
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
      if params[:location_id] != nil
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
      	      logger.error "Price Points #{@pass_set.price_points.inspect}"
      	      @pass_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
      	      logger.error "Price Points #{@pass_set.price_points.inspect}"
      	      check_active = true
      	      @pass_set.price_points.each_with_index.map {|price, index| 
      	        price.num_sold = 0
      	        if @pass_set.price_points[index+1] != nil
      	            price.num_released = price.active_less_than - @pass_set.price_points[index+1].active_less_than
      	            price.num_unsold = price.active_less_than - @pass_set.price_points[index+1].active_less_than
      	        else
      	            price.num_released = price.active_less_than
      	            price.num_unsold = price.active_less_than
      	        end
      	        if @pass_set.unsold_passes <= price.active_less_than && @pass_set.unsold_passes > @pass_set.price_points[index+1].active_less_than && check_active == true
      	            price.active_check = true
      	            @pass_set.price = price.price
      	        else
      	            price.active_check = false
      	        end
      	      }
      	      logger.error "Price Points #{@pass_set.price_points.inspect}"
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
                  logger.error "Ticket Set Associated with Price Point #{@price_point.pass_set.inspect}"
                  format.html { redirect_to [@location.user, @location], notice: 'Pass set was successfully created.' }
                  format.json { render json: @pass_set, status: :created, location: @pass_set }
              else
                  format.html { render action: "new" }
                  format.json { render json: @pass_set.errors, status: :unprocessable_entity }
              end
          end
      elsif params[:event_id] != nil
          @event_fechas = @event.fechas.where("date = ?", @fecha.date)
          @existing_set = @event_fechas.first
          logger.error "No Change: #{no_change}"
          logger.error "Fechas: #{@event_fechas.empty?}"
          logger.error "Fechas: #{@existing_set.inspect}"
          if @event_fechas.empty?
              @fecha.event = @event
              @fecha.pass_set = @pass_set
              @fecha.selling_passes = true
              @pass_set.sold_passes = 0
    	        @pass_set.unsold_passes = @pass_set.total_released_passes
    	        @pass_set.revenue_percentage = 0.7
    	        @pass_set.revenue_total = 0
    	        @pass_set.event = @event
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
    	        @pass_set.event = @event
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
				          format.html { redirect_to edit_user_event_pass_set_path(@event.user, @event, @existing_set.pass_set) }
				          format.json { render json: @pass_set.errors, status: :unprocessable_entity }
              elsif @pass_set.save
                  @fecha.pass_set = @pass_set
                  @fecha.save!
                  logger.error "Fecha Values: #{@fecha.inspect}"
                  @price_point.pass_set_id = @pass_set.id
                  @price_point.save!
                  logger.error "Ticket Set Associated with Price Point #{@price_point.pass_set.inspect}"
                  format.html { redirect_to [@event.user, @event], notice: 'Pass set was successfully created.' }
                  format.json { render json: @pass_set, status: :created, location: @pass_set }
              else
                  format.html { render action: "new" }
                  format.json { render json: @pass_set.errors, status: :unprocessable_entity }
              end
          end      
      end
  end

  # PUT /pass_sets/1
  # PUT /pass_sets/1.json
  def update
      @pass_set = PassSet.find(params[:id])
	    @date = Date.new(params[:pass_set][:fecha_attributes]["date(1i)"].to_i,params[:pass_set][:fecha_attributes]["date(2i)"].to_i,params[:pass_set][:fecha_attributes]["date(3i)"].to_i)
      if params[:location_id] != nil
          @location = Location.find(params[:location_id])
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
      elsif params[:event_id] != nil
          @event = Event.find(params[:event_id])
          @existing_set = @event.fechas.where("date = ?", @date).first.pass_set
    	    logger.error "Ticket Set: #{@existing_set.inspect}"
          if @existing_set.nil?
              logger.error "Nil Existing Set"
              flash[:notice] = "Error: You cannot change the date of this pass set. Please create a new one"
              redirect_to :action => "index", :controller => "events"
              return
          end
          @pass_set.unsold_passes = Integer(params[:pass_set]["total_released_passes"]) - @pass_set.sold_passes
          @existing_sets = @event.fechas.where("date = ? and selling_passes = ?", @date, true).length
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
                  format.html { redirect_to [@event.user, @event], notice: 'Pass set was successfully updated.' }
                  format.json { head :no_content }
              else
                  format.html { render action: "edit" }
                  format.json { render json: @pass_set.errors, status: :unprocessable_entity }
              end
          end
      end
  end

  # DELETE /pass_sets/1
  # DELETE /pass_sets/1.json
  def destroy
      @pass_set = PassSet.find(params[:id])
      if @pass_set.location != nil
          @location = @pass_set.location
          @pass_set.destroy

          respond_to do |format|
            format.html { redirect_to [@location], notice: 'Pass set was successfully deleted.' }
            format.json { head :no_content }
          end
      elsif @pass_set.event != nil
          @event = @pass_set.event
          @pass_set.destroy

          respond_to do |format|
            format.html { redirect_to [@event], notice: 'Pass set was successfully deleted.' }
            format.json { head :no_content }
          end
      end
  end
  
  def close_set
      @pass_set = PassSet.find(params[:pass_set_id])
      @pass_set.total_released_passes = @pass_set.sold_passes
      @pass_set.unsold_passes = 0
      @pass_set.save
      
      if @pass_set.location != nil
          @location = @pass_set.location
          respond_to do |format|
              format.html { redirect_to [@location], notice: 'Pass set was successfully closed.' }
              format.json { head :no_content }
          end
      elsif @pass_set.event != nil
          @event = @pass_set.event
          respond_to do |format|
              format.html { redirect_to [@event], notice: 'Pass set was successfully closed.' }
              format.json { head :no_content }
          end
      end
  end
end