class TicketsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /tickets
  # GET /tickets.json
  def index
    @user = current_user
    # Eager loading pass sets on the user's passes
	  @valid_tickets = @user.tickets.joins(:ticket_set).where('pass_sets.date >= ?', Time.now.to_date).order('ticket_sets.date ASC').paginate(:page => params[:valid_ticket_page], :per_page => 5)
	  @past_tickets = @user.tickets.joins(:ticket_set).where('pass_sets.date < ?', Time.now.to_date).order('ticket_sets.date ASC').paginate(:page => params[:past_ticket_page], :per_page => 5)
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
    @user = current_user
	  @ticket = Ticket.find(params[:id])
	  if @ticket.purchase.stripe_charge_token != nil
	      @customer_card = Stripe::Charge.retrieve(@ticket.purchase.stripe_charge_token)
        @card_type = @customer_card.card.type
        @card_four = @customer_card.card.last4
    end
	  logger.error "Purchase #: #{@ticket.purchase}"
	  logger.error "Ticket User #: #{@ticket.purchase.user}"
	  logger.error "Real User #: #{@user}"
	  if(@user != @ticket.purchase.user)
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
      @ticket = Ticket.find(params[:id])
      if(@ticket.redeemed?)
          @ticket.redeemed=false
      else
          @ticket.redeemed=true
      end
      @ticket.save
      redirect_to :back
      flash[:notice] = "Redeem Toggled!"
  end
  
  def pdfversion
      @ticket = Ticket.find(params[:id])

      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [4,3]).bounding_box do
      	  pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
      	  pdf.text_box "<color rgb='888888'>#{@ticket.ticket_set.bar.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
      		pdf.text_box "<color rgb='888888'>#{@ticket.ticket_set.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [35,185], :height => 90, :width => 210, :size => 42
      	  pdf.text_box "<color rgb='888888'>#{@ticket.entries}</color>",:inline_format => true, :at => [115,136], :height => 25, :width => 123, :size => 24
      	  pdf.text_box "<color rgb='888888'>#{@ticket.name}</color>",:inline_format => true, :at => [38,108], :height => 55, :width => 195, :size => 18, :align => :center, :valign => :center
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

      if @pass.pass_set.selling_passes == true
          send_data pdf.render, :filename => "LISTDPASS(#{@ticket.confirmation}).pdf", :type => "application/pdf"
      else
          send_data pdf.render, :filename => "LISTDRESERVATION(#{@ticket.confirmation}).pdf", :type => "application/pdf"
      end
  end

  # GET /tickets/new
  # GET /tickets/new.json
  def new
    @ticket = Ticket.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticket }
    end
  end

  # GET /tickets/1/edit
  def edit
    @ticket = Ticket.find(params[:id])
  end

  # POST /tickets
  # POST /tickets.json
  def create
    @ticket = Ticket.new(params[:ticket])

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
        format.json { render json: @ticket, status: :created, location: @ticket }
      else
        format.html { render action: "new" }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tickets/1
  # PUT /tickets/1.json
  def update
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      if @ticket.update_attributes(params[:ticket])
        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy

    respond_to do |format|
      format.html { redirect_to tickets_url }
      format.json { head :no_content }
    end
  end
end
