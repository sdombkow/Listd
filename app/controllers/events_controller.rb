class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :search]
  before_filter :elevated_privilege_P? , :except => [:search,:show]
  before_filter :ownsEvent?, :only => [:edit,:update, :destroy]

  # Check if current user owns the location
  def ownsEvent?
      @event = Event.find(params[:id])
      if current_user.partner?
          if @event.user_id != current_user.id
              redirect_to @event
          end
      end
  end
  
  # GET /events
  # GET /events.json
  def index
    @user=current_user
    @events = @user.events

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    @user = @event.user
    @full_path = "http://#{request.host+request.fullpath}"
    
      @ticket_sets = @event.ticket_sets.joins(:fecha).where("date >= ?", Date.today).order(:date)
      @expired_ticket_sets = @event.ticket_sets.joins(:fecha).where("date < ?", Date.today).order(:date)
      @pass_sets = @event.pass_sets.joins(:fecha).where("fechas.date >= ?", Date.today).order(:date)
      @deal_sets = @event.deal_sets.joins(:fecha).where("fechas.date >= ?", Date.today).order(:date)
      @reservation_sets = @event.reservation_sets.joins(:fecha).where("fechas.date >= ?", Date.today).order(:date)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @user = User.find(params[:id])
    @event.user = @user
    @event.user_id= @user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @user = @event.user
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.address = @event.street_address + ", " + @event.city + ", " + @event.state + ", " + @event.zip_code
    @user = User.find(params[:os])
    @event.user = @user
    @event.user_id= @user.id

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
    @user = User.find(params[:os])
    @pass_set = @event.pass_sets.first
    
    if(current_user.admin?)
        respond_to do |format|
            if @event.update_attributes(params[:event])
                format.html { redirect_to user_event_path(@event.user,@event), notice: 'Event was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @event.errors, status: :unprocessable_entity }
            end
        end
    else
        respond_to do |format|
            if @event.update_attributes(params[:event])
                format.html { redirect_to event_path(@event), notice: 'Event was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @event.errors, status: :unprocessable_entity }
            end
        end
    end		
	  
	  @event.address = @event.street_address + " , " + @event.city + " , " + @event.state + " , " + @event.zip_code
    @event.save
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @user = @event.user
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
  
  def search
      @search = params[:search]
      @events = Event.search(@search)
      if @events.empty?
          redirect_to :controller=>'home', :action=>'welcome'
          flash[:notice] = "Your query did not match any of our partner bars or nightclubs."
      end
  end

end