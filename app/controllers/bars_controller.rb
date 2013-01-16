class BarsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :search]
  before_filter :isPartner? , :except => [:index,:search,:show]
  # GET /bars
  # GET /bars.json
  def index
    @user=current_user
	  @bars = @user.bars
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bars }
	end
  end
  
  # GET /bars/1
  # GET /bars/1.json
  def show
    @bar = Bar.find(params[:id])
	  @user = @bar.user
    @full_path = "http://#{request.host+request.fullpath}"
    @pass_sets = @bar.pass_sets.where("date >= ?", Date.today).order(:date)
	  @expired_sets= @bar.pass_sets.where("date< ?", Date.today).order(:date)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bar }
    end
  end

  # GET /bars/new
  # GET /bars/new.json
  def new
    @bar = Bar.new
	@user = User.find(params[:id])
	@bar.user = @user
	@bar.user_id= @user.id
   # @bar.pass_sets.build
   # We do not want to create a default pass set when form is submitted;
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bar }
    end
  end

  # GET /bars/1/edit
  def edit
    @bar = Bar.find(params[:id])
	@user = @bar.user
  end

  # POST /bars
  # POST /bars.json
  def create
    @bar = Bar.new(params[:bar])
	@bar.address = @bar.street_address + " , " + @bar.city + " , " + @bar.state + " , " + @bar.zip_code
	@user = User.find(params[:os])
	@bar.user = @user
	@bar.user_id= @user.id
    respond_to do |format|
      if @bar.save
        format.html { redirect_to  user_bar_path(@bar.user,@bar), notice: 'Bar was successfully created.' }
        format.json { render json: @bar, status: :created, location: @bar }
      else
        format.html { render action: "new" }
        format.json { render json: @bar.errors, status: :unprocessable_entity }
      end
    end
  end

def search
  @search = params[:search]
  @bars = Bar.search(@search)
  if @bars.empty?
      redirect_to :controller=>'home', :action=>'welcome'
       flash[:notice] = "No bars found matching your search."
  end
end

  # PUT /bars/1
  # PUT /bars/1.json
  def update
    @bar = Bar.find(params[:id])
	@user = User.find(params[:os])
    @pass_set = @bar.pass_sets.first
	if(current_user.admin?)
    respond_to do |format|
      if @bar.update_attributes(params[:bar])
        format.html { redirect_to user_bar_path(@bar.user,@bar), notice: 'Bar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bar.errors, status: :unprocessable_entity }
      end
    end
	else
	   respond_to do |format|
      if @bar.update_attributes(params[:bar])
        format.html { redirect_to bar_path(@bar), notice: 'Bar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bar.errors, status: :unprocessable_entity }
      end
	end
	end		
		@bar.address = @bar.street_address + " , " + @bar.city + " , " + @bar.state + " , " + @bar.zip_code
	@bar.save
  end

  # DELETE /bars/1
  # DELETE /bars/1.json
  def destroy
	@bar = Bar.find(params[:id])
	@user = @bar.user
    @bar.destroy
    respond_to do |format|
      format.html { redirect_to @user, notice: 'Bar was successfully deleted.'}
      format.json { head :no_content }
    end

  end
  
end


