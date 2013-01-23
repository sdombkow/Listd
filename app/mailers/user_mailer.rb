class UserMailer < ActionMailer::Base
  default :from => "listdtest@gmail.com"

  def purchase_confirmation(user,pass)
   @user=user
   @pass=pass
    mail(:to => user.email, :subject => "Purchased Confirmed!")
  end
  
  def send_feedback(user)
   @user=user
   mail(:to => user.email, :subject => "Send Feedback!")
  end
end