class HomeController < ApplicationController
  def index
  end

  def welcome
    if user_signed_in?
      if current_user.admin?
        redirect_to :controller=>'admin'
      elsif current_user.partner?
        render 'pages/dashboard_temp'
      end
    end
    
    #acquires users ip address for geolocating
    
    #@user_info = request.ip
    @user_info = "71.118.168.149"
    
    #acquires all the needed information based on the users ip address
    
    @user_information = Geocoder.search(@user_info)
  
    #finds all local venues within 10 miles of that users location, orders them based
    #on distance from the user
    
    #@venues = Bar.near(@user_information[0].coordinates, 30, :order => :distance).take(1)
    @venues = Bar.all.take(1)
    if @venues.size < 3
      #@venues = Bar.near(@user_information[0].coordinates,3200, :order => :distance).take(1)
    end
    
    #@venues = Bar.all.take(3)
    #@localvenues = Bar.all
    
    #if someone has searched for venues and there are locatons within 20 miles of that
    #location displays them, if their are no local then it displays all bars, if their are
    #local venues it displays those
    if params[:search].present?
      @locations = Bar.near(params[:search], 50, :order => :distance)
    else
      @locations = @localvenues
    end
    
    if user_signed_in?
       @user = current_user
       # Eager loading pass sets
   	   @passes = @user.passes.where('redeemed = ?', false).joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date >= ?', true, Time.now.to_date).order('pass_sets.date ASC').limit(3)
   	   @weekly_passes = @user.weekly_passes.where('redeemed = ?', false).where('weekly_passes.valid_to >= ?', Time.now.to_date).order('weekly_passes.valid_from ASC').limit(3)
   	   @reservations = @user.passes.where('redeemed = ?', false).joins(:pass_set).where('pass_sets.selling_passes = ? AND pass_sets.date >= ?', false, Time.now.to_date).order('pass_sets.date ASC, passes.reservation_time ASC').limit(3)
   	end
  end

end
