class DealSetsController < ApplicationController
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deal_set }
    end
  end

  # GET /deal_sets/new
  # GET /deal_sets/new.json
  def new
    @deal_set = DealSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deal_set }
    end
  end

  # GET /deal_sets/1/edit
  def edit
    @deal_set = DealSet.find(params[:id])
  end

  # POST /deal_sets
  # POST /deal_sets.json
  def create
    @deal_set = DealSet.new(params[:deal_set])

    respond_to do |format|
      if @deal_set.save
        format.html { redirect_to @deal_set, notice: 'Deal set was successfully created.' }
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

    respond_to do |format|
      if @deal_set.update_attributes(params[:deal_set])
        format.html { redirect_to @deal_set, notice: 'Deal set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deal_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deal_sets/1
  # DELETE /deal_sets/1.json
  def destroy
    @deal_set = DealSet.find(params[:id])
    @deal_set.destroy

    respond_to do |format|
      format.html { redirect_to deal_sets_url }
      format.json { head :no_content }
    end
  end
end
