class LocationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :search]
  before_filter :elevated_privilege_P? , :except => [:search,:show]
  before_filter :ownsLocation?, :only => [:edit,:update, :destroy]

  # Check if current user owns the location
  def ownsLocation?
      @location = Location.find(params[:id])
      if current_user.partner?
          if @location.user_id != current_user.id
              redirect_to @location
          end
      end
  end
  
  # GET /locations
  # GET /locations.json
  def index
    @user=current_user
    @locations = @user.locations

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find(params[:id])
    @user = @location.user
    @full_path = "http://#{request.host+request.fullpath}"
    logger.error "Ticket Sets #{@location.ticket_sets}"
    
    @ticket_sets = @location.ticket_sets.joins(:fecha).where("date >= ?", Date.today).order(:date)
    @expired_ticket_sets= @location.ticket_sets.joins(:fecha).where("date< ?", Date.today).order(:date)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @location = Location.new
    @user = User.find(params[:id])
    @location.user = @user
    @location.user_id= @user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
    @user = @location.user
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(params[:location])
    @location.full_address = @location.street_address + ", " + @location.city + ", " + @location.state + ", " + @location.zip_code
    @user = User.find(params[:os])
    @location.user = @user
    @location.user_id= @user.id

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created, location: @location }
      else
        format.html { render action: "new" }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @location = Location.find(params[:id])
    @user = User.find(params[:os])
    @pass_set = @location.pass_sets.first
    
    if(current_user.admin?)
        respond_to do |format|
            if @location.update_attributes(params[:location])
                format.html { redirect_to user_location_path(@location.user,@location), notice: 'Location was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @location.errors, status: :unprocessable_entity }
            end
        end
    else
        respond_to do |format|
            if @location.update_attributes(params[:location])
                format.html { redirect_to location_path(@location), notice: 'Location was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @location.errors, status: :unprocessable_entity }
            end
        end
    end		
	  
	  @location.address = @location.street_address + " , " + @location.city + " , " + @location.state + " , " + @location.zip_code
    @location.save
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location = Location.find(params[:id])
    @user = @location.user
    @location.destroy

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end
  
  def search
      @search = params[:search]
      @locations = Location.search(@search)
      if @locations.empty?
          redirect_to :controller=>'home', :action=>'welcome'
          flash[:notice] = "Your query did not match any of our partner bars or nightclubs."
      end
  end
  
end