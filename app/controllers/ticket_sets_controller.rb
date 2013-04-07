class TicketSetsController < ApplicationController
  # GET /ticket_sets
  # GET /ticket_sets.json
  def index
    @ticket_sets = TicketSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ticket_sets }
    end
  end

  # GET /ticket_sets/1
  # GET /ticket_sets/1.json
  def show
    @ticket_set = TicketSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/new
  # GET /ticket_sets/new.json
  def new
    @ticket_set = TicketSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticket_set }
    end
  end

  # GET /ticket_sets/1/edit
  def edit
    @ticket_set = TicketSet.find(params[:id])
  end

  # POST /ticket_sets
  # POST /ticket_sets.json
  def create
    @ticket_set = TicketSet.new(params[:ticket_set])

    respond_to do |format|
      if @ticket_set.save
        format.html { redirect_to @ticket_set, notice: 'Ticket set was successfully created.' }
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
    @ticket_set = TicketSet.find(params[:id])

    respond_to do |format|
      if @ticket_set.update_attributes(params[:ticket_set])
        format.html { redirect_to @ticket_set, notice: 'Ticket set was successfully updated.' }
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
    @ticket_set.destroy

    respond_to do |format|
      format.html { redirect_to ticket_sets_url }
      format.json { head :no_content }
    end
  end
end
