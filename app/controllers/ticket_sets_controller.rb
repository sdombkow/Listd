class TicketSetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_P? , :except => [:show]
  before_filter :ownsTicketSet, :only => [:edit,:update,:new,:delete,:create]
  
  # Ensure that the user owns the bar for this pass set
  def ownsTicketSet
      @bar = Bar.find(params[:bar_id])
      if current_user.partner? == false and current_user.admin? == false
          redirect_to @bar
      elsif current_user.partner? == true and @bar.user_id != current_user.id
          redirect_to @bar
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
    @bar = Bar.find(params[:bar_id])
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
    @full_bar_path = "http://#{request.host}" + (bar_path @ticket_set.bar).to_s
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
    @ticket_set.sold_passes = 0
    @ticket_set.unsold_tickets = @ticket_set.total_released_tickets
    @bar = Bar.find(params[:bar_id])
    @bar_label = "Bar ID for "<<@bar.name
    @ticket_set.bar = @bar
  
    respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/1/edit
  def edit
    @bar = Bar.find(params[:bar_id])
    @ticket_set = TicketSet.find(params[:id])
  end

  # POST /ticket_sets
  # POST /ticket_sets.json
  def create
    @ticket_set = TicketSet.new(params[:pass_set])
    @ticket_set.sold_passes = 0
	  @ticket_set.unsold_passes = @ticket_set.total_released_passes
    @bar = Bar.find(params[:bar_id])
    @ticket_set.bar = @bar
    @existing_set = @bar.ticket_sets.where("date = ?", @ticket_set.date).first
    
    respond_to do |format|
	      if @ticket_set.date < Date.today
	          flash[:notice] = 'Error: You are trying to create a ticket for a date that has already passed!'
            format.html { render action: "new"  }
            format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        elsif @existing_set
			      flash[:notice] = 'Error: Please use edit to change existing ticket'
			      format.html { redirect_to edit_user_bar_ticket_set_path(@bar.user, @bar, @existing_set) }
			      format.json { render json: @ticket_set.errors, status: :unprocessable_entity }
        elsif @ticket_set.save
            format.html { redirect_to [@bar.user, @bar], notice: 'Ticket set was successfully created.' }
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
    @bar = Bar.find(params[:bar_id])
    @ticket_set = TicketSet.find(params[:id])
    @date = Date.new(params[:ticket_set]["date(1i)"].to_i,params[:ticket_set]["date(2i)"].to_i,params[:ticket_set]["date(3i)"].to_i)
    @existing_set = @bar.ticket_sets.where("date = ?", @date).first
    if @existing_set.nil?
        logger.error "Nil Existing Set"
        flash[:notice] = "Error: You cannot change the date of this ticket set. Please create a new one"
        redirect_to :action => "index", :controller => "bars"
        return
    end
    @ticket_set.unsold_passes = Integer(params[:ticket_set]["total_released_passes"]) - @ticket_set.sold_passes
    @existing_sets = @bar.ticket_sets.where("date = ?", @date).length
      
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
            format.html { redirect_to [@bar.user, @bar], notice: 'Ticket set was successfully updated.' }
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
  
end