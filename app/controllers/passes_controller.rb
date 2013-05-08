require 'barby/barcode/qr_code'
require 'barby/outputter/prawn_outputter'
require 'rqrcode'

class PassesController < ApplicationController

  before_filter :authenticate_user!
  
  def index
    if current_user.partner == true
        redirect_to :root
    end
  	@user = current_user
    # Eager loading pass sets on the user's passes
  	@valid_passes = @user.passes.joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date >= ?', true, Time.now.to_date).order('pass_sets.date ASC').paginate(:page => params[:valid_passes_page], :per_page => 5)
  	@past_passes = @user.passes.joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date < ?', true, Time.now.to_date).order('pass_sets.date ASC').paginate(:page => params[:past_passes_page], :per_page => 5)
  end
  
  def reservation_archive
    @user = current_user
    # Eager loading pass sets on the user's passes
  	@valid_res = @user.passes.joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date >= ?', false, Time.now.to_date).order('pass_sets.date ASC, passes.reservation_time ASC').paginate(:page => params[:valid_res_page], :per_page => 5)
  	@past_res = @user.passes.joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date < ?', false, Time.now.to_date).order('pass_sets.date ASC, passes.reservation_time ASC').paginate(:page => params[:past_res_page], :per_page => 5)
  end 
  
  def show
		@user=current_user
		@pass = Pass.find(params[:id])
		if @pass.purchase.stripe_charge_token != nil
		  @customer_card = Stripe::Charge.retrieve(@pass.purchase.stripe_charge_token)
      @card_type = @customer_card.card.type
      @card_four = @customer_card.card.last4
    end
		logger.error "Purchase #: #{@pass.purchase}"
		logger.error "Pass User #: #{@pass.purchase.user}"
		logger.error "Real User #: #{@user}"
		if(@user != @pass.purchase.user)
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
   @pass = Pass.find_by_confirmation(params[:id])
   if current_user.partner?
     if @pass.pass_set.bar.user.id != current_user.id
       redirect_to :root
       return
     end
   end
   
   if(@pass.redeemed?)
     @pass.redeemed=false
   else
     @pass.redeemed=true
   end
   @pass.save
   back_url = "/bars/#{@pass.pass_set.bar_id}/pass_sets/#{@pass.pass_set_id}"
   redirect_to back_url
   flash[:notice] = "Redeem Toggled!"
  end
  
  def pdfversion
      @pass = Pass.find(params[:id])

      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [4,3]).bounding_box do
      	pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
      	pdf.text_box "<color rgb='888888'>#{@pass.pass_set.bar.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
        if @pass.reservation_time == nil
      		pdf.text_box "<color rgb='888888'>#{@pass.pass_set.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [35,185], :height => 90, :width => 210, :size => 42
      	else
      		pdf.text_box "<color rgb='888888'>#{@pass.reservation_time}</color>",:inline_format => true, :at => [80,205], :height => 90, :width => 210, :size => 24
      		pdf.text_box "<color rgb='888888'>#{@pass.pass_set.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [50,170], :height => 90, :width => 210, :size => 36
      	end
      	pdf.text_box "<color rgb='888888'>#{@pass.entries}</color>",:inline_format => true, :at => [115,136], :height => 25, :width => 123, :size => 24
      	pdf.text_box "<color rgb='888888'>#{@pass.name}</color>",:inline_format => true, :at => [38,108], :height => 55, :width => 195, :size => 18, :align => :center, :valign => :center
      end

      pdf.grid([0,4], [4,7]).bounding_box do
      	pdf.image "#{Rails.root}/app/assets/images/get_listed_text.png", :width => 250, :position => :center, :vposition => :center
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 50

      if @pass.pass_set.selling_passes == true
      	pdf.font "Helvetica"
      	pdf.text "Pass Instructions", :size => 20, :align => :center
      	pdf.move_down 20
      	pdf.text "1. If possible, download and print LISTD pass."
      	pdf.move_down 10
      	pdf.text "2. When arriving at the bar or nightclub, have LISTD pass available as a print out or on your mobile device."
      	pdf.move_down 10
      	pdf.text "3. Show your LISTD pass and photo ID at the door."
      	pdf.move_down 10
      	pdf.text "4. Gain immediate entry and enjoy your night!"
      else
      	pdf.font "Helvetica"
      	pdf.text "Reservation Instructions", :size => 20, :align => :center
      	pdf.move_down 20
      	pdf.text "1. Arrive at designated time and date, inform the location of your reservation."
      	pdf.move_down 10
      	pdf.text "2. If needed, show your LISTD confirmation."
      	pdf.move_down 10
      	pdf.text "3. Enjoy your meal!"
      end

        pdf.grid([4,6],[7,6]).bounding_box do
          @redeem_url = "#{request.protocol}#{request.host_with_port}/passes/toggleRedeem?id=#{@pass.confirmation}"
          Barby::QrCode.new(@redeem_url, :size => 7).annotate_pdf(pdf, :xdim => 2)
        end

      pdf.encrypt_document(:permissions => { :print_document => true,
      	:modify_contents => false,
      	:copy_contents => false,
      	:modify_annotations => false })
      	
      if @pass.pass_set.selling_passes == true
          send_data pdf.render, :filename => "LISTDPASS(#{@pass.confirmation}).pdf", :type => "application/pdf"
      else
          send_data pdf.render, :filename => "LISTDRESERVATION(#{@pass.confirmation}).pdf", :type => "application/pdf"
      end
  end

  def mobile_code
    pass = Pass.find_by_confirmation(params[:id])
    if pass.nil? == false and pass.purchase.user_id == current_user.id
        respond_to do |format|
          @redeem_url = "#{request.protocol}#{request.host_with_port}/passes/toggleRedeem?id=#{pass.confirmation}"
          @qr = RQRCode::QRCode.new(@redeem_url, :size => 9)
          format.html { render :layout => false }
        end
    else
        redirect_to :root
    end
  end
end
