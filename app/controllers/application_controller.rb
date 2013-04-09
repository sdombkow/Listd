class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def elevated_privilege_P?
	    if current_user.admin?
	    else
	        unless current_user.partner?
	            redirect_to :controller=>'home'
	        end
	    end
  end
	
  def elevated_privilege_A?
	    unless current_user.admin?
	        redirect_to :controller=>'home'
	    end
	end
end