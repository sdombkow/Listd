class ReservationSetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsReservationSet, :only => [:edit,:update,:new,:delete,:create]
  
  # Ensure that the user owns the bar for this deal set
  def ownsReservationSet
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
  
  # GET /reservation_sets
  # GET /reservation_sets.json
  def index
    @reservation_sets = ReservationSet.where("reservation_set_id = ? and created_at > ?", params[:reservation_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /reservation_sets/1
  # GET /reservation_sets/1.json
  def show
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @reservation_set = ReservationSet.find(params[:id])
        @full_bar_path = "http://#{request.host}" + (location_path @reservation_set.location).to_s
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @reservation_set = ReservationSet.find(params[:id])
        @full_bar_path = "http://#{request.host}" + (event_path @reservation_set.event).to_s
    end
    @used_reservations = @reservation_set.reservations.order("name DESC").where('redeemed = ?', true).paginate(:page => params[:used_dreservations_page], :per_page => 5)
    @unused_reservations = @reservation_set.reservations.order("name DESC").where('redeemed = ?', false).paginate(:page => params[:unused_reservations_page], :per_page => 5)
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
    if flash[:notice] == 'Reservation created'
        @open_graph = true
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reservation_set }
    end
  end

  # GET /reservation_sets/new
  # GET /reservation_sets/new.json
  def new
    @reservation_set = ReservationSet.new
    @reservation_set.build_fecha
    @reservation_set.build_price_point
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @location_label = "Location ID for "<< @location.name
    elsif params[:event_id] != nil
        @location = Event.find(params[:event_id])
        @location_label = "Event ID for "<< @event.name
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reservation_set }
    end
  end

  # GET /reservation_sets/1/edit
  def edit
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
    end
    @reservation_set = ReservationSet.find(params[:id])
    logger.error "Deal Set Price: #{@reservation_set.price_point.price}"
  end

  # POST /reservation_sets
  # POST /reservation_sets.json
  def create
    @reservation_set = ReservationSet.new(params[:reservation_set])
    @fecha = Fecha.new(params[:reservation_set][:fecha_attributes])
    @price_point = PricePoint.new(params[:reservation_set][:price_point_attributes])
    logger.error "Reservation Set Values: #{@reservation_set.inspect}"
    logger.error "Fecha Values: #{@fecha.inspect}"
    logger.error "Price Point Values: #{@price_point.inspect}"
    no_change = false
    if params[:location_id] != nil
        @location_fechas = @location.fechas.where("date = ?", @fecha.date)
        @existing_set = @location_fechas.first
        logger.error "Fechas: #{@location_fechas.inspect}"
        if @location_fechas.empty?
            @fecha.location = @location
            @fecha.reservation_set = @reservation_set
            @fecha.selling_reservations = true
            @reservation_set.sold_reservations = 0
    	      @reservation_set.unsold_reservations = @reservation_set.total_released_reservations
    	      @reservation_set.revenue_percentage = 0.7
    	      @reservation_set.revenue_total = 0
    	      @reservation_set.location = @location
    	      @reservation_set.fecha = @fecha
    	      @price_point.num_released = @reservation_set.total_released_reservations
    	      @price_point.num_sold = 0
    	      @price_point.num_unsold = @reservation_set.total_released_reservations
        elsif @existing_set.selling_reservations == false
            logger.error "In Existing Set"
            @fecha = @existing_set
            @fecha.reservation_set = @reservation_set
            @fecha.selling_reservations = true
            @reservation_set.sold_reservations = 0
    	      @reservation_set.unsold_reservations = @reservation_set.total_released_reservations
            @reservation_set.revenue_percentage = 0.7
      	    @reservation_set.revenue_total = 0
            @reservation_set.location = @location
      	    @reservation_set.fecha = @fecha
    	      @price_point.num_released = @reservation_set.total_released_reservations
            @price_point.num_sold = 0
      	    @price_point.num_unsold = 0
        else       
            no_change = true
          end
        logger.error "Reservation Set: #{@existing_set.inspect}"
    
        respond_to do |format|
            if @fecha.date < Date.today
	              flash[:notice] = 'Error: You are trying to create a reservation set for a date that has already passed!'
                format.html { render action: "new"  }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif no_change == true
                logger.error "Here"
				        flash[:notice] = 'Error: Please use edit to change existing reservations'
				        format.html { redirect_to edit_user_location_reservation_set_path(@location.user, @location, @existing_set.reservation_set) }
				        format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif @reservation_set.save
                @fecha.reservation_set = @reservation_set
                @fecha.save!
                @price_point.reservation_set_id = @reservation_set.id
                @price_point.save!
                logger.error "Reservation Set Associated with Price Point #{@price_point.reservation_set.inspect}"
                format.html { redirect_to [@location.user, @location], notice: 'Reservation set was successfully created.' }
                format.json { render json: @reservation_set, status: :created, location: @reservation_set }
            else
                format.html { render action: "new" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            end
        end
    elsif params[:event_id] != nil
        @event_fechas = @event.fechas.where("date = ?", @fecha.date)
        @existing_set = @event_fechas.first
        logger.error "Fechas: #{@event_fechas.inspect}"
        if @event_fechas.empty?
            @fecha.event = @event
            @fecha.reservation_set = @reservation_set
            @fecha.selling_reservations = true
            @reservation_set.sold_reservations = 0
    	      @reservation_set.unsold_reservations = @reservation_set.total_released_reservations
    	      @reservation_set.revenue_percentage = 0.7
    	      @reservation_set.revenue_total = 0
    	      @reservation_set.event = @event
    	      @reservation_set.fecha = @fecha
    	      @price_point.num_released = @reservation_set.total_released_reservations
    	      @price_point.num_sold = 0
    	      @price_point.num_unsold = @reservation_set.total_released_reservations
        elsif @existing_set.selling_reservations == false
            logger.error "In Existing Set"
            @fecha = @existing_set
            @fecha.reservation_set = @reservation_set
            @fecha.selling_reservations = true
            @reservation_set.sold_reservations = 0
    	      @reservation_set.unsold_reservations = @reservation_set.total_released_reservations
            @reservation_set.revenue_percentage = 0.7
      	    @reservation_set.revenue_total = 0
            @reservation_set.event = @event
      	    @reservation_set.fecha = @fecha
    	      @price_point.num_released = @reservation_set.total_released_reservations
            @price_point.num_sold = 0
      	    @price_point.num_unsold = 0
        else       
            no_change = true
          end
        logger.error "Reservation Set: #{@existing_set.inspect}"
    
        respond_to do |format|
            if @fecha.date < Date.today
	              flash[:notice] = 'Error: You are trying to create a reservation set for a date that has already passed!'
                format.html { render action: "new"  }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif no_change == true
                logger.error "Here"
				        flash[:notice] = 'Error: Please use edit to change existing reservations'
				        format.html { redirect_to edit_user_event_reservation_set_path(@event.user, @event, @existing_set.reservation_set) }
				        format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif @reservation_set.save
                @fecha.reservation_set = @reservation_set
                @fecha.save!
                @price_point.reservation_set_id = @reservation_set.id
                @price_point.save!
                logger.error "Reservation Set Associated with Price Point #{@price_point.reservation_set.inspect}"
                format.html { redirect_to [@event.user, @event], notice: 'Reservation set was successfully created.' }
                format.json { render json: @reservation_set, status: :created, location: @reservation_set }
            else
                format.html { render action: "new" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            end
        end
    end
  end

  # PUT /reservation_sets/1
  # PUT /reservation_sets/1.json
  def update
    @reservation_set = ReservationSet.find(params[:id])
    @date = Date.new(params[:reservation_set][:fecha_attributes]["date(1i)"].to_i,params[:reservation_set][:fecha_attributes]["date(2i)"].to_i,params[:reservation_set][:fecha_attributes]["date(3i)"].to_i)
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @existing_set = @location.fechas.where("date = ?", @date).first.reservation_set
        logger.error "Fecha Values #{@location.fechas.where("date = ?", @date).first.inspect}"
        logger.error "Reservation Set: #{@existing_set.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this reservation set. Please create a new one"
            redirect_to :action => "index", :controller => "locations"
            return
        end
        @reservation_set.unsold_reservations = Integer(params[:reservation_set]["total_released_reservations"]) - @reservation_set.sold_reservations
        @existing_sets = @location.fechas.where("date = ? and selling_reservations = ?", @date, true).length
        logger.error "Price: #{params[:reservation_set][:price_point_attributes]}"
        @reservation_set.price_point.price = params[:reservation_set][:price_point_attributes]["price"]
        logger.error "Reservation Set Price: #{@reservation_set.price_point.price}"
      
        respond_to do |format|
            if @date < Date.today
	              flash[:notice] = 'Error: You are trying to edit a reservation to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @reservation_set.id
  	            flash[:notice] = 'Error: There is already a reservation set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif @reservation_set.update_attributes(params[:reservation_set])
                format.html { redirect_to [@location.user, @location], notice: 'Reservation set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            end
        end
      elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @existing_set = @event.fechas.where("date = ?", @date).first.reservation_set
        logger.error "Reservation Set: #{@existing_set.inspect}"
        logger.error "Fecha Values: #{@event.fechas.where("date = ?", @date).first.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this reservation set. Please create a new one"
            redirect_to :action => "index", :controller => "events"
            return
        end
        @reservation_set.unsold_reservations = Integer(params[:reservation_set]["total_released_reservations"]) - @reservation_set.sold_reservations
        @existing_sets = @event.fechas.where("date = ? and selling_reservations = ?", @date, true).length
        logger.error "Price: #{params[:reservation_set][:price_point_attributes]}"
        @reservation_set.price_point.price = params[:reservation_set][:price_point_attributes]["price"]
        logger.error "Reservation Set Price: #{@reservation_set.price_point.price}"
      
        respond_to do |format|
            if @date < Date.today
	              flash[:notice] = 'Error: You are trying to edit a reservation to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @reservation_set.id
  	            flash[:notice] = 'Error: There is already a reservation set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            elsif @reservation_set.update_attributes(params[:reservation_set])
                format.html { redirect_to [@event.user, @event], notice: 'Reservation set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
            end
        end
      end
  end

  # DELETE /reservation_sets/1
  # DELETE /reservation_sets/1.json
  def destroy
      @reservation_set = ReservationSet.find(params[:id])
      if @reservation_set.location != nil
          @location = @reservation_set.location
          @reservation_set.destroy

          respond_to do |format|
            format.html { redirect_to [@location], notice: 'Reservation set was successfully deleted.' }
            format.json { head :no_content }
          end
      elsif @reservation_set.event != nil
          @event = @reservation_set.event
          @reservation_set.destroy

          respond_to do |format|
            format.html { redirect_to [@event], notice: 'Reservation set was successfully deleted.' }
            format.json { head :no_content }
          end
      end
  end
  
  def close_set
      @reservation_set = ReservationSet.find(params[:reservation_set_id])
      @reservation_set.total_released_reservations = @reservation_set.sold_reservations
      @reservation_set.unsold_reservations = 0
      @reservation_set.save
    
      if @reservation_set.location != nil
          @location = @reservation_set.location
          respond_to do |format|
              format.html { redirect_to [@location], notice: 'Reservation set was successfully closed.' }
              format.json { head :no_content }
          end
      elsif @reservation_set.event != nil
          @event = @reservation_set.event
          respond_to do |format|
              format.html { redirect_to [@event], notice: 'Reservation set was successfully closed.' }
              format.json { head :no_content }
          end
      end
  end
  
  def extra
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
  end
  
end