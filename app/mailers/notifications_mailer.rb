class NotificationsMailer < ActionMailer::Base

  default :from => "listdtest@gmail.com"
  default :to => "questions@listdnow.com"

  def new_message(message)
    @message = message
    mail(:subject => "[listdnow.com] #{message.subject}")
  end

end