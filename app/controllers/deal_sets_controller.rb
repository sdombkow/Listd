class DealSetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsDealSet, :only => [:edit,:update,:new,:delete,:create]
  
  # Ensure that the user owns the bar for this deal set
  def ownsDealSet
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
  
  # GET /deal_sets
  # GET /deal_sets.json
  def index
    @deal_sets = DealSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deal_sets }
    end
  end

  # GET /deal_sets/1
  # GET /deal_sets/1.json
  def show
    @deal_set = DealSet.find(params[:id])
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @full_bar_path = "http://#{request.host}" + (location_path @deal_set.location).to_s
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @full_bar_path = "http://#{request.host}" + (event_path @deal_set.event).to_s
    end
    @used_deals = @deal_set.deals.order("name DESC").where('redeemed = ?', true).paginate(:page => params[:used_deals_page], :per_page => 5)
    @unused_deals = @deal_set.deals.order("name DESC").where('redeemed = ?', false).paginate(:page => params[:unused_deals_page], :per_page => 5)
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
      format.json { render json: @deal_set }
    end
  end

  # GET /deal_sets/new
  # GET /deal_sets/new.json
  def new
    @deal_set = DealSet.new
    @deal_set.build_fecha
    1.times { @deal_set.price_points.build }
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @location_label = "Location ID for "<< @location.name
    elsif params[:event_id] != nil
        @location = Event.find(params[:event_id])
        @location_label = "Event ID for "<< @event.name
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deal_set }
    end
  end

  # GET /deal_sets/1/edit
  def edit
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
    end
    @deal_set = DealSet.find(params[:id])
  end

  # POST /deal_sets
  # POST /deal_sets.json
  def create
      @deal_set = DealSet.new(params[:deal_set])
      @fecha = Fecha.new(params[:deal_set][:fecha_attributes])
      logger.error "Ticket Set Values: #{@deal_set.inspect}"
      logger.error "Fecha Values: #{@fecha.inspect}"
      logger.error "Price Point Values: #{@price_point.inspect}"
      no_change = false
      if params[:location_id] != nil
          location_not_event = true
      else
          location_not_event = false
      end
      @deal_set.sold_deals = 0
      @deal_set.unsold_deals = @deal_set.total_released_deals
      @deal_set.revenue_percentage = 0.7
      @deal_set.revenue_total = 0
      @deal_set.location = @location
      @deal_set.fecha = @fecha
      logger.error "Price Points #{@deal_set.price_points.inspect}"
      @deal_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
      logger.error "Price Points #{@deal_set.price_points.inspect}"
      check_active = true
      @deal_set.price_points.each_with_index.map {|price, index| 
          price.num_sold = 0
          if @deal_set.price_points[index+1] != nil
              price.num_released = price.active_less_than - @deal_set.price_points[index+1].active_less_than
              price.num_unsold = price.active_less_than - @deal_set.price_points[index+1].active_less_than
          else
              price.num_released = price.active_less_than
              price.num_unsold = price.active_less_than
          end
          if @deal_set.price_points[index+1] != nil && @deal_set.unsold_deals <= price.active_less_than && @deal_set.unsold_deals > @deal_set.price_points[index+1].active_less_than && check_active == true
              price.active_check = true
              @deal_set.price = price.price
          elsif @deal_set.price_points[index+1] == nil && @deal_set.unsold_deals <= price.active_less_than && check_active == true
              price.active_check = true
              @deal_set.price = price.price
          else
              price.active_check = false
          end
      }
      logger.error "Price Points #{@deal_set.price_points.inspect}" 
      if location_not_event == true
          @establishment_fechas = @location.fechas.where("date = ?", @fecha.date)
      else
          @establishment_fechas = @event.fechas.where("date = ?", @fecha.date)
      end
      @existing_set = @establishment_fechas.first
      if @establishment_fechas.empty?
          if location_not_event == true
              @fecha.location = @location
          elsif location_not_event == false     
              @fecha.event = @event
          end 
          @fecha.deal_set = @deal_set
          @fecha.selling_deals = true
      elsif @existing_set.selling_deals == false
          logger.error "In Existing Set"
          @fecha = @existing_set
          @fecha.deal_set = @deal_set
          @fecha.selling_deals = true
      else       
          no_change = true
      end    
      logger.error "Deal Set: #{@existing_set.inspect}" 
      respond_to do |format|
          if @fecha.date < Date.today
              flash[:notice] = 'Error: You are trying to create a deal set for a date that has already passed!'
              format.html { render action: "new"  }
              format.json { render json: @deal_set.errors, status: :unprocessable_entity }
          elsif no_change == true
              logger.error "Here"
  	          flash[:notice] = 'Error: Please use edit to change existing deals'
  	          if location_not_event == true
  	              format.html { redirect_to edit_user_location_deal_set_path(@location.user, @location, @existing_set.deal_set) }
  	          else
  	              format.html { redirect_to edit_user_event_deal_set_path(@event.user, @event, @existing_set.deal_set) }
  	          end
  	          format.json { render json: @deal_set.errors, status: :unprocessable_entity }
          elsif @deal_set.save
              @fecha.deal_set = @deal_set
              @fecha.save!
              if location_not_event == true
                  format.html { redirect_to [@location.user, @location], notice: 'Deal set was successfully created.' }
              else
                  format.html { redirect_to [@event.user, @event], notice: 'Deal set was successfully created.' }
              end
              format.json { render json: @deal_set, status: :created, location: @deal_set }
          else
              format.html { render action: "new" }
              format.json { render json: @deal_set.errors, status: :unprocessable_entity }
          end
      end
  end

  # PUT /deal_sets/1
  # PUT /deal_sets/1.json
  def update
    @deal_set = DealSet.find(params[:id])
    @date = Date.new(params[:deal_set][:fecha_attributes]["date(1i)"].to_i,params[:deal_set][:fecha_attributes]["date(2i)"].to_i,params[:deal_set][:fecha_attributes]["date(3i)"].to_i)
    if params[:location_id] != nil
        @location = Location.find(params[:location_id])
        @existing_set = @location.fechas.where("date = ?", @date).first.deal_set
        logger.error "Reservation Set: #{@existing_set.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this deal set. Please create a new one"
            redirect_to :action => "index", :controller => "locations"
            return
        end
        @deal_set.unsold_deals = Integer(params[:deal_set]["total_released_deals"]) - @deal_set.sold_deals
        @existing_sets = @location.fechas.where("date = ? and selling_deals = ?", @date, true).length
        logger.error "Price: #{params[:deal_set][:price_point_attributes]}"
        @deal_set.price_point.price = params[:deal_set][:price_point_attributes]["price"]
        logger.error "Deal Set Price: #{@deal_set.price_point.price}"
      
        respond_to do |format|
            if @date < Date.today
	              flash[:notice] = 'Error: You are trying to edit a deal to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @deal_set.id
  	            flash[:notice] = 'Error: There is already a deal set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
            elsif @deal_set.update_attributes(params[:deal_set])
                logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      @deal_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
        	      logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      check_active = true
        	      @deal_set.price_points.each_with_index.map {|price, index| 
        	        price.num_sold = 0
        	        if @deal_set.price_points[index+1] != nil
        	            price.num_released = price.active_less_than - @deal_set.price_points[index+1].active_less_than
        	            price.num_unsold = price.active_less_than - @deal_set.price_points[index+1].active_less_than
        	        else
        	            price.num_released = price.active_less_than
        	            price.num_unsold = price.active_less_than
        	        end
        	        if @deal_set.price_points[index+1] != nil && @deal_set.unsold_deals <= price.active_less_than && @ticket_set.unsold_deals > @ticket_set.price_points[index+1].active_less_than && check_active == true
        	            price.active_check = true
        	            @deal_set.price = price.price
        	        elsif @deal_set.price_points[index+1] == nil && @deal_set.unsold_deals <= price.active_less_than && check_active == true
          	          price.active_check = true
                      @deal_set.price = price.price
        	        else
        	            price.active_check = false
        	        end
        	      }
        	      logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      @deal_set.update_attributes(params[:deal_set])
                format.html { redirect_to [@location.user, @location], notice: 'Deal set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
            end
        end 
    elsif params[:event_id] != nil
        @event = Event.find(params[:event_id])
        @existing_set = @event.fechas.where("date = ?", @date).first.deal_set
        logger.error "Reservation Set: #{@existing_set.inspect}"
        logger.error "Fecha Values: #{@event.fechas.where("date = ?", @date).first.inspect}"
        if @existing_set.nil?
            logger.error "Nil Existing Set"
            flash[:notice] = "Error: You cannot change the date of this deal set. Please create a new one"
            redirect_to :action => "index", :controller => "events"
            return
        end
        @deal_set.unsold_deals = Integer(params[:deal_set]["total_released_deals"]) - @deal_set.sold_deals
        @existing_sets = @event.fechas.where("date = ? and selling_deals = ?", @date, true).length
        logger.error "Price: #{params[:deal_set][:price_point_attributes]}"
        @deal_set.price_point.price = params[:deal_set][:price_point_attributes]["price"]
        logger.error "Deal Set Price: #{@deal_set.price_point.price}"
      
        respond_to do |format|
            if @date < Date.today
	              flash[:notice] = 'Error: You are trying to edit a deal to a date that has already passed!'
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
                # Next if statements prevents any editing to this pass set
            elsif @existing_sets == 1 and @existing_set.id != @deal_set.id
  	            flash[:notice] = 'Error: There is already a deal set with this date!'
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
            elsif @deal_set.update_attributes(params[:deal_set])
                logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      @deal_set.price_points.sort{|p1,p2| p1.active_less_than <=> p2.active_less_than}
        	      logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      check_active = true
        	      @deal_set.price_points.each_with_index.map {|price, index| 
        	        price.num_sold = 0
        	        if @deal_set.price_points[index+1] != nil
        	            price.num_released = price.active_less_than - @deal_set.price_points[index+1].active_less_than
        	            price.num_unsold = price.active_less_than - @deal_set.price_points[index+1].active_less_than
        	        else
        	            price.num_released = price.active_less_than
        	            price.num_unsold = price.active_less_than
        	        end
        	        if @deal_set.price_points[index+1] != nil && @deal_set.unsold_deals <= price.active_less_than && @deal_set.unsold_deals > @deal_set.price_points[index+1].active_less_than && check_active == true
        	            price.active_check = true
        	            @deal_set.price = price.price
        	        elsif @deal_set.price_points[index+1] == nil && @deal_set.unsold_deals <= price.active_less_than && check_active == true
          	          price.active_check = true
                      @deal_set.price = price.price  
        	        else
        	            price.active_check = false
        	        end
        	      }
        	      logger.error "Price Points #{@deal_set.price_points.inspect}"
        	      @deal_set.update_attributes(params[:deal_set])
                format.html { redirect_to [@event.user, @event], notice: 'Deal set was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @deal_set.errors, status: :unprocessable_entity }
            end
        end
    end
  end

  # DELETE /deal_sets/1
  # DELETE /deal_sets/1.json
  def destroy
      @deal_set = DealSet.find(params[:id])
      if @deal_set.location != nil
          @location = @deal_set.location
          @deal_set.destroy

          respond_to do |format|
            format.html { redirect_to [@location], notice: 'Deal set was successfully deleted.' }
            format.json { head :no_content }
          end
      elsif @deal_set.event != nil
          @event = @deal_set.event
          @deal_set.destroy

          respond_to do |format|
            format.html { redirect_to [@event], notice: 'Deal set was successfully deleted.' }
            format.json { head :no_content }
          end
      end
  end
  
  def close_set
      @deal_set = DealSet.find(params[:deal_set_id])
      @deal_set.total_released_deals = @deal_set.sold_deals
      @deal_set.unsold_deals = 0
      @deal_set.save
      
      if @deal_set.location != nil
          @location = @deal_set.location
          respond_to do |format|
              format.html { redirect_to [@location], notice: 'Deal set was successfully closed.' }
              format.json { head :no_content }
          end
      elsif @deal_set.event != nil
          @event = @deal_set.event
          respond_to do |format|
              format.html { redirect_to [@event], notice: 'Deal set was successfully closed.' }
              format.json { head :no_content }
          end
      end
  end
end
