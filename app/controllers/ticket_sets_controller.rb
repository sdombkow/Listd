class TicketSetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsTicketSet, :only => [:edit,:update,:new,:delete,:create]
  
  # Ensure that the user owns the bar for this pass set
  def ownsTicketSet
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
  
  # GET /ticket_sets
  # GET /ticket_sets.json
  def index
    @tickets = Ticket.where("ticket_set_id = ? and created_at > ?", params[:ticket_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /ticket_sets/1
  # GET /ticket_sets/1.json
  def show
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @ticket_set = TicketSet.find(params[:id])
        @full_bar_path = "http://#{request.host}" + (location_path @ticket_set.location).to_s
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @ticket_set = TicketSet.find(params[:id])
        @full_bar_path = "http://#{request.host}" + (event_path @ticket_set.event).to_s
    end
    @used_tickets = @ticket_set.tickets.order("name DESC").where('redeemed = ?', true).paginate(:page => params[:used_tickets_page], :per_page => 5)
    @unused_tickets = @ticket_set.tickets.order("name DESC").where('redeemed = ?', false).paginate(:page => params[:unused_tickets_page], :per_page => 5)
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
        format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/new
  # GET /ticket_sets/new.json
  def new
    @ticket_set = TicketSet.new
    @ticket_set.build_fecha
    1.times { @ticket_set.price_points.build }
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @location_label = "Location ID for "<< @location.name
    elsif params[:event_id] != nil
        @location = Event.find(params[:event_id])
        @location_label = "Event ID for "<< @event.name
    end
  
    respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/1/edit
  def edit
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
    end
    @ticket_set = TicketSet.find(params[:id])
  end

  # POST /ticket_sets
  # POST /ticket_sets.json
  def create
    @ticket_set = TicketSet.new(params[:ticket_set])
    @fecha = Fecha.new(params[:ticket_set][:fecha_attributes])
    @price_point = PricePoint.new(params[:ticket_set][:price_point_attributes])
    logger.error "Ticket Set Values: #{@ticket_set.inspect}"
    logger.error "Fecha Values: #{@fecha.inspect}"
    logger.error "Price Point Values: #{@price_point.inspect}"
    no_change = false
    if params[:location_id] != nil
        @location_fechas = @location.fechas.where("date = ?", @fecha.date)
        @existing_set = @location_fechas.first
        logger.error "Fechas: #{@location_fechas.empty?}"
        if @location_fechas.empty?
            @fecha.location = @location
            @fecha.ticket_set = @ticket_set
            @fecha.selling_tickets = true
            @ticket_set.sold_tickets = 0
    	      @ticket_set.unsold_tickets = @ticket_set.total_released_tickets
    	      @ticket_set.revenue_percentage = 0.7
    	      @ticket_set.revenue_total = 0
    	      @ticket_set.location = @location
    	      @ticket_set.fecha = @fecha
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      check_active = true
    	      @ticket_set.price_points.each_with_index.map {|price, index| 
    	        price.num_sold = 0
    	        if @ticket_set.price_points[index+1] != nil
    	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	        else
    	            price.num_released = price.active_less_than
    	            price.num_unsold = price.active_less_than
    	        end
    	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets <= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
    	            price.active_check = true
    	            @ticket_set.price = price.price
    	        else
    	            price.active_check = false
    	        end
    	      }
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @price_point.num_released = @ticket_set.total_released_tickets
    	      @price_point.num_sold = 0
    	      @price_point.num_unsold = 0
    	      @existing_set = @location_fechas.first
        elsif @existing_set.selling_tickets == false
            logger.error "In Existing Set"
            @fecha = @existing_set
            @fecha.ticket_set = @ticket_set
            @fecha.selling_tickets = true
            @ticket_set.sold_tickets = 0
            @ticket_set.unsold_tickets = @ticket_set.total_released_tickets
      	    @ticket_set.revenue_percentage = 0.7
      	    @ticket_set.revenue_total = 0
      	    @ticket_set.location = @location
      	    @ticket_set.fecha = @fecha
      	    logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      check_active = true
    	      @ticket_set.price_points.each_with_index.map {|price, index| 
    	        price.num_sold = 0
    	        if @ticket_set.price_points[index+1] != nil
    	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	        else
    	            price.num_released = price.active_less_than
    	            price.num_unsold = price.active_less_than
    	        end
    	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets <= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
    	            price.active_check = true
    	            @ticket_set.price = price.price
    	        else
    	            price.active_check = false
    	        end
    	      }
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
      	    @price_point.num_released = @ticket_set.total_released_tickets
      	    @price_point.num_sold = 0
      	    @price_point.num_unsold = 0
        else       
            no_change = true
        end  
    
        respond_to do |format|
            if @fecha.date < Date.today
	              flash[:notice] = 'Error: You are trying to create a ticket set for a date that has already passed!'
                format.html { render action: "new"  }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            elsif no_change == true
                logger.error "Here"
				        flash[:notice] = 'Error: Please use edit to change existing tickets'
				        format.html { redirect_to edit_user_location_ticket_set_path(@location.user, @location, @existing_set.ticket_set) }
				        format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
              elsif @ticket_set.save
                @fecha.ticket_set = @ticket_set
                @fecha.save!
                logger.error "Fecha: #{@fecha.inspect}"
                logger.error "Ticket Set Associated with Price Point #{@price_point.ticket_set.inspect}"
                format.html { redirect_to [@location.user, @location], notice: 'Ticket set was successfully created.' }
                format.json { render json: @ticket_set, status: :created, location: @ticket_set }
            else
              format.html { render action: "new" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            end
        end
    elsif params[:event_id] != nil
        @event_fechas = @event.fechas.where("date = ?", @fecha.date)
        @existing_set = @event_fechas.first
        logger.error "Fechas: #{@event_fechas.empty?}"
        if @event_fechas.empty?
            @fecha.event = @event
            @fecha.ticket_set = @ticket_set
            @fecha.selling_tickets = true
            @ticket_set.sold_tickets = 0
    	      @ticket_set.unsold_tickets = @ticket_set.total_released_tickets
    	      @ticket_set.revenue_percentage = 0.7
    	      @ticket_set.revenue_total = 0
    	      @ticket_set.event = @event
    	      @ticket_set.fecha = @fecha
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      check_active = true
    	      @ticket_set.price_points.each_with_index.map {|price, index| 
    	        price.num_sold = 0
    	        if @ticket_set.price_points[index+1] != nil
    	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	        else
    	            price.num_released = price.active_less_than
    	            price.num_unsold = price.active_less_than
    	        end
    	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets <= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
    	            price.active_check = true
    	            @ticket_set.price = price.price
    	        else
    	            price.active_check = false
    	        end
    	      }
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @price_point.num_released = @ticket_set.total_released_tickets
    	      @price_point.num_sold = 0
    	      @price_point.num_unsold = 0
    	      @existing_set = @event_fechas.first
        elsif @existing_set.selling_tickets == false
            logger.error "In Existing Set"
            @fecha = @existing_set
            @fecha.ticket_set = @ticket_set
            @fecha.selling_tickets = true
            @ticket_set.sold_tickets = 0
            @ticket_set.unsold_tickets = @ticket_set.total_released_tickets
      	    @ticket_set.revenue_percentage = 0.7
      	    @ticket_set.revenue_total = 0
      	    @ticket_set.event = @event
      	    @ticket_set.fecha = @fecha
      	    logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
    	      check_active = true
    	      @ticket_set.price_points.each_with_index.map {|price, index| 
    	        price.num_sold = 0
    	        if @ticket_set.price_points[index+1] != nil
    	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
    	        else
    	            price.num_released = price.active_less_than
    	            price.num_unsold = price.active_less_than
    	        end
    	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets <= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
    	            price.active_check = true
    	            @ticket_set.price = price.price
    	        else
    	            price.active_check = false
    	        end
    	      }
    	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
      	    @price_point.num_released = @ticket_set.total_released_tickets
      	    @price_point.num_sold = 0
      	    @price_point.num_unsold = 0
        else       
            no_change = true
        end  
    
        respond_to do |format|
            if @fecha.date < Date.today
	              flash[:notice] = 'Error: You are trying to create a ticket set for a date that has already passed!'
                format.html { render action: "new"  }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            elsif no_change == true
                logger.error "Here"
				        flash[:notice] = 'Error: Please use edit to change existing tickets'
				        format.html { redirect_to edit_user_event_ticket_set_path(@event.user, @event, @existing_set.ticket_set) }
				        format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
              elsif @ticket_set.save
                @fecha.ticket_set = @ticket_set
                @fecha.save!
                logger.error "Fecha: #{@fecha.inspect}"
                logger.error "Ticket Set Associated with Price Point #{@price_point.ticket_set.inspect}"
                format.html { redirect_to [@event.user, @event], notice: 'Ticket set was successfully created.' }
                format.json { render json: @ticket_set, status: :created, location: @ticket_set }
            else
              format.html { render action: "new" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            end
        end
    end
  end

  # PUT /ticket_sets/1
  # PUT /ticket_sets/1.json
  def update
    @ticket_set = TicketSet.find(params[:id])
    @date = Date.new(params[:ticket_set][:fecha_attributes]["date(1i)"].to_i,params[:ticket_set][:fecha_attributes]["date(2i)"].to_i,params[:ticket_set][:fecha_attributes]["date(3i)"].to_i)
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @existing_set = @location.fechas.where("date = ?", @date).first.ticket_set
        logger.error "Ticket Set: #{@existing_set.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this ticket set. Please create a new one"
            redirect_to :action => "index", :controller => "locations"
            return
        end
        @ticket_set.unsold_tickets = Integer(params[:ticket_set]["total_released_tickets"]) - @ticket_set.sold_tickets
        @existing_sets = @location.fechas.where("date = ? and selling_tickets = ?", @date, true).length
        logger.error "Price: #{params[:ticket_set][:price_point_attributes]}"
        @ticket_set.price_point.price = params[:ticket_set][:price_point_attributes]["price"]
        logger.error "Ticket Set Price: #{@ticket_set.price_point.price}"
      
        respond_to do |format|
            if @date < Date.today
	              flash[:notice] = 'Error: You are trying to edit a ticket to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @ticket_set.id
  	            flash[:notice] = 'Error: There is already a ticket set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            elsif @ticket_set.update_attributes(params[:ticket_set])
                logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
        	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      check_active = true
        	      @ticket_set.price_points.each_with_index.map {|price, index| 
        	        price.num_sold = 0
        	        if @ticket_set.price_points[index+1] != nil
        	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
        	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
        	        else
        	            price.num_released = price.active_less_than
        	            price.num_unsold = price.active_less_than
        	        end
        	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets <= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
        	            price.active_check = true
        	            @ticket_set.price = price.price
        	        else
        	            price.active_check = false
        	        end
        	      }
        	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      @ticket_set.update_attributes(params[:ticket_set])
                format.html { redirect_to [@location.user, @location], notice: 'Ticket set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            end
        end
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @existing_set = @event.fechas.where("date = ?", @date).first.ticket_set
        logger.error "Ticket Set: #{@existing_set.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this ticket set. Please create a new one"
            redirect_to :action => "index", :controller => "events"
            return
        end
        @ticket_set.unsold_tickets = Integer(params[:ticket_set]["total_released_tickets"]) - @ticket_set.sold_tickets
        @existing_sets = @event.fechas.where("date = ? and selling_tickets = ?", @date, true).length
        logger.error "Price: #{params[:ticket_set][:price_point_attributes]}"
        @ticket_set.price_point.price = params[:ticket_set][:price_point_attributes]["price"]
        logger.error "Ticket Set Price: #{@ticket_set.price_point.price}"
    
        respond_to do |format|
            if @date < Date.today
                flash[:notice] = 'Error: You are trying to edit a ticket to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @ticket_set.id
	              flash[:notice] = 'Error: There is already a ticket set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            elsif @ticket_set.update_attributes(params[:ticket_set])
                logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      @ticket_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
        	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      check_active = true
        	      @ticket_set.price_points.each_with_index.map {|price, index| 
        	        price.num_sold = 0
        	        if @ticket_set.price_points[index+1] != nil
        	            price.num_released = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
        	            price.num_unsold = price.active_less_than - @ticket_set.price_points[index+1].active_less_than
        	        else
        	            price.num_released = price.active_less_than
        	            price.num_unsold = price.active_less_than
        	        end
        	        if @ticket_set.price_points[index+1] != nil && @ticket_set.unsold_tickets<= price.active_less_than && @ticket_set.unsold_tickets > @ticket_set.price_points[index+1].active_less_than && check_active == true
        	            price.active_check = true
        	            @ticket_set.price = price.price
        	        else
        	            price.active_check = false
        	        end
        	      }
        	      logger.error "Price Points #{@ticket_set.price_points.inspect}"
        	      @ticket_set.update_attributes(params[:ticket_set])
                format.html { redirect_to [@event.user, @event], notice: 'Ticket set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
            end
        end
    end
  end

  # DELETE /ticket_sets/1
  # DELETE /ticket_sets/1.json
  def destroy
    @ticket_set = TicketSet.find(params[:id])
    if @ticket_set.location != nil
        @location = @ticket_set.location
        @ticket_set.destroy

        respond_to do |format|
          format.html { redirect_to [@location], notice: 'Ticket set was successfully deleted.' }
          format.json { head :no_content }
        end
    elsif @ticket_set.event != nil
        @event = @ticket_set.event
        @ticket_set.destroy

        respond_to do |format|
          format.html { redirect_to [@event], notice: 'Ticket set was successfully deleted.' }
          format.json { head :no_content }
        end
    end
  end
  
  def close_set
      @ticket_set = TicketSet.find(params[:ticket_set_id])
      @ticket_set.total_released_tickets = @ticket_set.sold_tickets
      @ticket_set.unsold_tickets = 0
      @ticket_set.save
    
      if @ticket_set.location != nil
          @location = @ticket_set.location
          respond_to do |format|
              format.html { redirect_to [@location], notice: 'Ticket set was successfully closed.' }
              format.json { head :no_content }
          end
      elsif @ticket_set.event != nil
          @event = @ticket_set.event
          respond_to do |format|
              format.html { redirect_to [@event], notice: 'Ticket set was successfully closed.' }
              format.json { head :no_content }
          end
      end
  end
end