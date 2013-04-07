class DiaController < ApplicationController
  # GET /dia
  # GET /dia.json
  def index
    @dia = Dium.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dia }
    end
  end

  # GET /dia/1
  # GET /dia/1.json
  def show
    @dium = Dium.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dium }
    end
  end

  # GET /dia/new
  # GET /dia/new.json
  def new
    @dium = Dium.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dium }
    end
  end

  # GET /dia/1/edit
  def edit
    @dium = Dium.find(params[:id])
  end

  # POST /dia
  # POST /dia.json
  def create
    @dium = Dium.new(params[:dium])

    respond_to do |format|
      if @dium.save
        format.html { redirect_to @dium, notice: 'Dium was successfully created.' }
        format.json { render json: @dium, status: :created, location: @dium }
      else
        format.html { render action: "new" }
        format.json { render json: @dium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dia/1
  # PUT /dia/1.json
  def update
    @dium = Dium.find(params[:id])

    respond_to do |format|
      if @dium.update_attributes(params[:dium])
        format.html { redirect_to @dium, notice: 'Dium was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dia/1
  # DELETE /dia/1.json
  def destroy
    @dium = Dium.find(params[:id])
    @dium.destroy

    respond_to do |format|
      format.html { redirect_to dia_url }
      format.json { head :no_content }
    end
  end
end
