class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :elevated_privilege_A?

  def index  
      @numOfCustomers= User.where("partner = 'f' AND admin='f'").count('email', :distinct => true)
      @numOfPartners= User.where("partner = 't'").count('email', :distinct => true)
  end

  def customers
      @customers = User.where("partner = 'f' AND admin='f'").order(:email).paginate(:page => params[:page], :per_page => 10)
  end

  def partners
      @partners = User.where("partner = 't'").order(:email).paginate(:page => params[:page], :per_page => 10)
  end  
end