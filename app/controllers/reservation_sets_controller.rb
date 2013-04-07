class ReservationSetsController < ApplicationController
  # GET /reservation_sets
  # GET /reservation_sets.json
  def index
    @reservation_sets = ReservationSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reservation_sets }
    end
  end

  # GET /reservation_sets/1
  # GET /reservation_sets/1.json
  def show
    @reservation_set = ReservationSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reservation_set }
    end
  end

  # GET /reservation_sets/new
  # GET /reservation_sets/new.json
  def new
    @reservation_set = ReservationSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reservation_set }
    end
  end

  # GET /reservation_sets/1/edit
  def edit
    @reservation_set = ReservationSet.find(params[:id])
  end

  # POST /reservation_sets
  # POST /reservation_sets.json
  def create
    @reservation_set = ReservationSet.new(params[:reservation_set])

    respond_to do |format|
      if @reservation_set.save
        format.html { redirect_to @reservation_set, notice: 'Reservation set was successfully created.' }
        format.json { render json: @reservation_set, status: :created, location: @reservation_set }
      else
        format.html { render action: "new" }
        format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reservation_sets/1
  # PUT /reservation_sets/1.json
  def update
    @reservation_set = ReservationSet.find(params[:id])

    respond_to do |format|
      if @reservation_set.update_attributes(params[:reservation_set])
        format.html { redirect_to @reservation_set, notice: 'Reservation set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reservation_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservation_sets/1
  # DELETE /reservation_sets/1.json
  def destroy
    @reservation_set = ReservationSet.find(params[:id])
    @reservation_set.destroy

    respond_to do |format|
      format.html { redirect_to reservation_sets_url }
      format.json { head :no_content }
    end
  end
end
