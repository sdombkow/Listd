class TicketSetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsTicketSet, :only => [:edit,:update,:new,:delete,:create]
  
  # Ensure that the user owns the bar for this pass set
  def ownsTicketSet
      @location = Location.find(params[:location_id])
      if current_user.partner? == false and current_user.admin? == false
          redirect_to @location
      elsif current_user.partner? == true and @location.user_id != current_user.id
          redirect_to @location
      end
      return
  end
  
  # GET /ticket_sets
  # GET /ticket_sets.json
  def index
    @tickets = Ticket.where("ticket_set_id = ? and created_at > ?", params[:ticket_set_id], Time.at(params[:after].to_i + 1))
  end

  # GET /ticket_sets/1
  # GET /ticket_sets/1.json
  def show
    @location = Location.find(params[:location_id])
    @ticket_set = TicketSet.find(params[:id])
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
    @full_location_path = "http://#{request.host}" + (location_path @ticket_set.location).to_s
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
    @ticket_set.build_price_point
    @location = Location.find(params[:location_id])
    @location_label = "Location ID for "<< @location.name
    #@ticket_set.bar = @bar
  
    respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/1/edit
  def edit
    @location = Location.find(params[:location_id])
    @ticket_set = TicketSet.find(params[:id])
    logger.error "Ticket Set Price: #{@ticket_set.price_point.price}"
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
    @location_fechas = @location.fechas.where("date = ?", @fecha.date)
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
    	  @price_point.num_released = @ticket_set.total_released_tickets
    	  @price_point.num_sold = 0
    	  @price_point.num_unsold = 0
    	  @existing_set = @location_fechas
    else
        @existing_set = @location_fechas
    end  
    
    respond_to do |format|
        if @fecha.date < Date.today
	          flash[:notice] = 'Error: You are trying to create a ticket set for a date that has already passed!'
            format.html { render action: "new"  }
            format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        elsif @existing_set.empty? == false
            logger.error "Here"
				    flash[:notice] = 'Error: Please use edit to change existing tickets'
				    format.html { redirect_to edit_user_location_ticket_set_path(@location.user, @location, @ticket_set) }
				    format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        elsif @ticket_set.save
            @fecha.ticket_set = @ticket_set
            @fecha.save!
            @price_point.ticket_set_id = @ticket_set.id
            @price_point.save!
            logger.error "Ticket Set Associated with Price Point #{@price_point.ticket_set.inspect}"
            format.html { redirect_to [@location.user, @location], notice: 'Ticket set was successfully created.' }
            format.json { render json: @ticket_set, status: :created, location: @ticket_set }
        else
            format.html { render action: "new" }
            format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        end
    end
  end

  # PUT /ticket_sets/1
  # PUT /ticket_sets/1.json
  def update
    @location = Location.find(params[:location_id])
    @ticket_set = TicketSet.find(params[:id])
    @date = Date.new(params[:ticket_set][:fecha_attributes]["date(1i)"].to_i,params[:ticket_set][:fecha_attributes]["date(2i)"].to_i,params[:ticket_set][:fecha_attributes]["date(3i)"].to_i)
    @existing_set = @location.fechas.where("date = ?", @date).first.ticket_set
    logger.error "Ticket Set: #{@existing_set.inspect}"
    if @existing_set.nil?
        logger.error "Nil Existing Set"
        flash[:notice] = "Error: You cannot change the date of this ticket set. Please create a new one"
        redirect_to :action => "index", :controller => "location"
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
            format.html { redirect_to [@location.user, @location], notice: 'Ticket set was successfully updated.' }
            format.json { head :no_content }
        else
            format.html { render action: "edit" }
            format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        end
    end
  end

  # DELETE /ticket_sets/1
  # DELETE /ticket_sets/1.json
  def destroy
    @ticket_set = TicketSet.find(params[:id])
    @bar = @ticket_set.bar
    @ticket_set.destroy

    respond_to do |format|
      format.html { redirect_to [@bar], notice: 'Ticket set was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def close_set
      @ticket_set = TicketSet.find(params[:ticket_set_id])
      @location = @ticket_set.location
      @ticket_set.total_released_tickets = @ticket_set.sold_tickets
      @ticket_set.unsold_tickets = 0
      @ticket_set.save
    
      respond_to do |format|
          format.html { redirect_to [@location], notice: 'Ticket set was successfully closed.' }
          format.json { head :no_content }
      end
  end
  
end