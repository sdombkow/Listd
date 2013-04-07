class FechasController < ApplicationController
  # GET /fechas
  # GET /fechas.json
  def index
    @fechas = Fecha.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fechas }
    end
  end

  # GET /fechas/1
  # GET /fechas/1.json
  def show
    @fecha = Fecha.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fecha }
    end
  end

  # GET /fechas/new
  # GET /fechas/new.json
  def new
    @fecha = Fecha.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fecha }
    end
  end

  # GET /fechas/1/edit
  def edit
    @fecha = Fecha.find(params[:id])
  end

  # POST /fechas
  # POST /fechas.json
  def create
    @fecha = Fecha.new(params[:fecha])

    respond_to do |format|
      if @fecha.save
        format.html { redirect_to @fecha, notice: 'Fecha was successfully created.' }
        format.json { render json: @fecha, status: :created, location: @fecha }
      else
        format.html { render action: "new" }
        format.json { render json: @fecha.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fechas/1
  # PUT /fechas/1.json
  def update
    @fecha = Fecha.find(params[:id])

    respond_to do |format|
      if @fecha.update_attributes(params[:fecha])
        format.html { redirect_to @fecha, notice: 'Fecha was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fecha.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fechas/1
  # DELETE /fechas/1.json
  def destroy
    @fecha = Fecha.find(params[:id])
    @fecha.destroy

    respond_to do |format|
      format.html { redirect_to fechas_url }
      format.json { head :no_content }
    end
  end
end
