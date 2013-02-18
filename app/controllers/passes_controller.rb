class PassesController < ApplicationController

  before_filter :authenticate_user!
  
  def index
  	@user = current_user
    # Eager loading pass sets on the user's passes
  	@valid_passes = @user.passes.includes(:pass_set).where('date >= ?', Time.now.to_date).order('updated_at DESC').paginate(:page => params[:valid_passes_page], :per_page => 5)
  	@past_passes = @user.passes.includes(:pass_set).where('date < ?', Time.now.to_date).order('updated_at DESC').paginate(:page => params[:past_passes_page], :per_page => 5)
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
		logger.error "User #: #{@pass.purchase.user}"
		if(@user != @pass.purchase.user)
		  if(!@user.partner?)
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
   @pass = Pass.find(params[:id])
   if(@pass.redeemed?)
   @pass.redeemed=false
   else
   @pass.redeemed=true
   end
   @pass.save
   redirect_to :back
   flash[:notice] = "Redeem Toggled!"
  end
  
  def pdfversion
      @pass = Pass.find(params[:id])

      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [3,3]).bounding_box do
      	pdf.image "#{Rails.root}/app/assets/images/pass_watermark_bg.png", :width => 200, :position => :center, :vposition => :center
      	pdf.text_box "<color rgb='888888'>#{@pass.pass_set.bar.name}</color>",:inline_format => true, :at => [55,240], :height => 80, :width => 170, :size => 20
      	pdf.text_box "<color rgb='888888'>#{@pass.pass_set.date.strftime("%m/%d/%Y")}</color>",:inline_format => true, :at => [60,147], :height => 50, :width => 170, :size => 32
      	pdf.text_box "<color rgb='888888'>#{@pass.entries}</color>",:inline_format => true, :at => [125,105], :height => 15, :width => 110, :size => 18
      	pdf.text_box "<color rgb='888888'>#{@pass.name}</color>",:inline_format => true, :at => [55,80], :height => 50, :width => 160, :size => 20, :align => :center
      end

      pdf.grid([0,4], [3,7]).bounding_box do
      	pdf.image "#{Rails.root}/app/assets/images/get_listed_text.png", :width => 225, :position => :center, :vposition => :center
      end

      pdf.move_down 40
      pdf.stroke_horizontal_rule
      pdf.move_down 50

      pdf.font "Helvetica"
      pdf.text "Pass Instructions", :size => 20, :align => :center
      pdf.move_down 20
      pdf.text "1. If possible, download and print LISTD pass."
      pdf.move_down 10
      pdf.text "2. When arriving at the bar or nightclub, have LISTD pass available as a print out or on your mobile device."
      pdf.move_down 10
      pdf.text "3. Skip the line and show your LISTD pass and photo ID at the door."
      pdf.move_down 10
      pdf.text "4. Gain immediate entry and enjoy your night!"

      pdf.grid([7,2], [7,5]).bounding_box do
      	pdf.image "#{Rails.root}/app/assets/images/logo_14.png", :width => 150, :position => :center, :vposition => :center
      end
      
      pdf.encrypt_document(:permissions => { :print_document => true,
      	:modify_contents => false,
      	:copy_contents => false,
      	:modify_annotations => false })

      send_data pdf.render, :filename => "LISTDPASS(#{@pass.confirmation}).pdf", :type => "application/pdf"
  end
end
