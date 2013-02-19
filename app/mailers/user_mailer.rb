class UserMailer < ActionMailer::Base
  default :from => "listdtest@gmail.com"

  def purchase_confirmation(user,pass)
   @user=user
   @pass=pass
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
   	
   attachments["LISTDPASS(#{@pass.confirmation}).pdf"] = pdf.render
   mail(:to => user.email, :subject => "Purchased Confirmed!")
  end
  
  def send_feedback(user)
   @user=user
   mail(:to => user.email, :subject => "Send Feedback!")
  end
end