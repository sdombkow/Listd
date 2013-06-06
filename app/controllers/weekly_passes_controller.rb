class WeeklyPassesController < ApplicationController
  # GET /weekly_passes
  # GET /weekly_passes.json
  def index
    if current_user.partner == true
        redirect_to :root
    end
  	@user = current_user
    # Eager loading pass sets on the user's passes
  	@valid_passes = @user.weekly_passes.where('weekly_passes.valid_to >= ?', Time.now.to_date).order('weekly_passes.valid_from ASC').paginate(:page => params[:valid_passes_page], :per_page => 5)
  	@past_passes = @user.weekly_passes.where('weekly_passes.valid_to < ?', Time.now.to_date).order('weekly_passes.valid_from ASC').paginate(:page => params[:past_passes_page], :per_page => 5)
  end

  # GET /weekly_passes/1
  # GET /weekly_passes/1.json
  def show
    @user=current_user
		@pass = WeeklyPass.find(params[:id])
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
  
  def pdfversion
      @pass = WeeklyPass.find(params[:id])

       pdf = Prawn::Document.new
       pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
       #pdf.grid.show_all

       pdf.font "Courier"
       pdf.grid([0,0], [4,3]).bounding_box do
       	pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
       	pdf.text_box "<color rgb='888888'>#{@pass.week_pass.bar.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
       		pdf.text_box "<color rgb='888888'></color>",:inline_format => true, :at => [80,205], :height => 90, :width => 210, :size => 24
       		pdf.text_box "<color rgb='888888'></color>",:inline_format => true, :at => [50,170], :height => 90, :width => 210, :size => 36
       	pdf.text_box "<color rgb='888888'>#{@pass.entries}</color>",:inline_format => true, :at => [115,136], :height => 25, :width => 123, :size => 24
       	pdf.text_box "<color rgb='888888'>#{@pass.name}</color>",:inline_format => true, :at => [38,108], :height => 55, :width => 195, :size => 18, :align => :center, :valign => :center
       end

       pdf.grid([0,4], [4,7]).bounding_box do
       	pdf.image "#{Rails.root}/app/assets/images/get_listed_text.png", :width => 250, :position => :center, :vposition => :center
       end

       pdf.stroke_horizontal_rule
       pdf.move_down 50

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

       pdf.encrypt_document(:permissions => { :print_document => true,
       	:modify_contents => false,
       	:copy_contents => false,
       	:modify_annotations => false })

        send_data pdf.render, :filename => "LISTDWEEKLYPASS(#{@pass.confirmation}).pdf", :type => "application/pdf"
  end
  
  def mobile_code
    pass = WeeklyPass.find_by_confirmation(params[:id])
    if pass.nil? == false and pass.purchase.user_id == current_user.id
        respond_to do |format|
          @redeem_url = "#{request.protocol}#{request.host_with_port}/weekly_passes/toggleRedeem?id=#{pass.confirmation}"
          @qr = RQRCode::QRCode.new(@redeem_url, :size => 9)
          format.html { render :layout => false }
        end
    else
        redirect_to :root
    end
  end
  
  def toggleRedeem
      @pass = WeeklyPass.find_by_confirmation(params[:id])
      logger.error "Pass: #{@pass}"
      if current_user.partner?
          if @pass.week_pass.bar.user.id != current_user.id
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
      logger.error "Pass Saved"
      back_url = "/bars/#{@pass.week_pass.bar_id}/week_passes/#{@pass.week_pass_id}"
      redirect_to back_url
      flash[:notice] = "Redeem Toggled!"
  end

end
