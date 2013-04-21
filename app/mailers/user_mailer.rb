class UserMailer < ActionMailer::Base
  default :from => "listdtest@gmail.com"

  def purchase_confirmation_ticket(user,pass)
      @user=user
      @pass=pass
      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [4,3]).bounding_box do
   	      pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
   	      pdf.text_box "<color rgb='888888'>#{@pass.ticket_set.location.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
   		    pdf.text_box "<color rgb='888888'>#{@pass.ticket_set.fecha.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [35,185], :height => 90, :width => 210, :size => 42
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

      attachments["LISTDPASS(#{@pass.confirmation}).pdf"] = pdf.render
   	
      mail(:to => user.email, :subject => "Purchased Confirmed!")
  end
  
  def purchase_confirmation_pass(user,pass)
      @user=user
      @pass=pass
      pdf = Prawn::Document.new
      pdf.define_grid(:columns => 8, :rows => 8, :gutter => 0)
      #pdf.grid.show_all

      pdf.font "Courier"
      pdf.grid([0,0], [4,3]).bounding_box do
   	      pdf.image "#{Rails.root}/app/assets/images/pass_reserv_bg.png", :width => 240, :position => :center, :vposition => :center
   	      pdf.text_box "<color rgb='888888'>#{@pass.pass_set.location.name}</color>",:inline_format => true, :at => [38,295], :height => 90, :width => 200, :size => 21
   		    pdf.text_box "<color rgb='888888'>#{@pass.pass_set.fecha.date.strftime("%m/%d/%y")}</color>",:inline_format => true, :at => [35,185], :height => 90, :width => 210, :size => 42
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

      attachments["LISTDPASS(#{@pass.confirmation}).pdf"] = pdf.render
   	
      mail(:to => user.email, :subject => "Purchased Confirmed!")
  end
  
  def friend_confirmation(name,email,pass)
      @friend = name
      @pass = pass
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
     	    pdf.text_box "<color rgb='888888'>#{@friend}</color>",:inline_format => true, :at => [38,108], :height => 55, :width => 195, :size => 18, :align => :center, :valign => :center
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

      pdf.encrypt_document(:permissions => { :print_document => true,
     	    :modify_contents => false,
     	    :copy_contents => false,
     	    :modify_annotations => false })

      if @pass.pass_set.selling_passes == true
          attachments["LISTDPASS(#{@pass.confirmation}).pdf"] = pdf.render
      else
          attachments["LISTDRESERVATION(#{@pass.confirmation}).pdf"] = pdf.render
      end
      mail(:to => email, :subject => "Purchase Confirmed!")
  end
  
  def send_feedback(user)
      @user=user
      mail(:to => user.email, :subject => "Send Feedback!")
  end
end