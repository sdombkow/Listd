class ReservationsController < ApplicationController
  # GET /reservations
  # GET /reservations.json
  def index
     @user = current_user
      # Eager loading pass sets on the user's passes
  	  @valid_reservations = @user.reservations.joins(:reservation_set => :fecha).where('fechas.date >= ?', Time.now.to_date).order('fechas.date ASC').paginate(:page => params[:valid_reservations_page], :per_page => 5)
  	  @past_reservations = @user.reservations.joins(:reservation_set => :fecha).where('fechas.date < ?', Time.now.to_date).order('fechas.date ASC').paginate(:page => params[:past_reservations_page], :per_page => 5)
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @user = current_user
	  @reservation = Reservation.find(params[:id])
	  if @reservation.purchase.stripe_charge_token != nil
	      @customer_card = Stripe::Charge.retrieve(@reservation.purchase.stripe_charge_token)
        @card_type = @customer_card.card.type
        @card_four = @customer_card.card.last4
    end
	  logger.error "Purchase #: #{@reservation.purchase}"
	  logger.error "Reservation User #: #{@reservation.purchase.user}"
	  logger.error "Real User #: #{@user}"
	  if(@user != @reservation.purchase.user)
	      if(!@user.partner? && !@user.admin?)
	          redirect_to:root
	          flash[:notice] = "Opps! You went somewhere you're not supposed to."
	      end
	  end
	
	  respond_to do |format|
        format.html
        format.pdf do
            render :pdf => "show.pdf.prawn"
        end
    end
  end
  
  def toggleRedeem
      @reservation = Reservation.find(params[:id])
      if(@reservation.redeemed?)
          @reservation.redeemed=false
      else
          @reservation.redeemed=true
      end
      @reservation.save
      redirect_to :back
      flash[:notice] = "Redeem Toggled!"
  end
  
  def pdfversion
      @reservation = Reservation.find(params[:id])

      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [4,3]).bounding_box do
      	  pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
      	  pdf.text_box "<color rgb='888888'>#{@reservation.reservation_set.location.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
      		pdf.text_box "<color rgb='888888'>#{@reservation.reservation_set.fecha.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [35,185], :height => 90, :width => 210, :size => 42
      	  pdf.text_box "<color rgb='888888'>#{@reservation.entries}</color>",:inline_format => true, :at => [115,136], :height => 25, :width => 123, :size => 24
      	  pdf.text_box "<color rgb='888888'>#{@reservation.name}</color>",:inline_format => true, :at => [38,108], :height => 55, :width => 195, :size => 18, :align => :center, :valign => :center
      end

      pdf.grid([0,4], [4,7]).bounding_box do
      	  pdf.image "#{Rails.root}/app/assets/images/get_listed_text.png", :width => 250, :position => :center, :vposition => :center
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 50

      pdf.font "Helvetica"
  	  pdf.text "Ticket Instructions", :size => 20, :align => :center
      pdf.move_down 20
      pdf.text "1. If possible, download and print LISTD pass."
  	  pdf.move_down 10
    	pdf.text "2. When arriving at the bar or nightclub, have LISTD pass available as a print out or on your mobile device."
      pdf.move_down 10
      pdf.text "3. Show your LISTD pass and photo ID at the door."
      pdf.move_down 10
      pdf.text "4. Gain immediate entry and enjoy your night!"
      
      pdf.encrypt_document(:permissions => { :print_document => true,
      	  :modify_contents => false,
      	  :copy_contents => false,
      	  :modify_annotations => false })

      send_data pdf.render, :filename => "LISTDRESERVATION(#{@reservation.confirmation}).pdf", :type => "application/pdf"
  end

  # GET /reservations/new
  # GET /reservations/new.json
  def new
    @reservation = Reservation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reservation }
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(params[:reservation])

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' }
        format.json { render json: @reservation, status: :created, location: @reservation }
      else
        format.html { render action: "new" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.json
  def update
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to reservations_url }
      format.json { head :no_content }
    end
  end
end
