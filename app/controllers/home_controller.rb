class HomeController < ApplicationController
  def index
  end

  def welcome
    if user_signed_in?
      if current_user.admin?
        redirect_to :controller=>'admin'
      elsif current_user.partner?
        redirect_to :controller=>'bars'
      end
    end
    
    #acquires users ip address for geolocating
    @user_info = request.location.city
    @user_info = "98.122.189.233"
    #acquires all the needed information based on the users ip address
    @user_information = Geocoder.search(@user_info)
    #while @user_information.empty?
    #@user_information = Geocoder.search(@user_info)
    #end
    #THIS WHILE LOOP FIXES THE NIL:CLASS CASE BUT IS PROBABLY NOT THE BEST WAY TO GO ABOUT IT
  
    #finds all local venues within 10 miles of that users location, orders them based
    #on distance from the user
    @localvenues = Bar.near(@user_information[0].coordinates, 30, :order => :distance)
    if @localvenues.size < 5
      @venues = Bar.near(@user_information[0].coordinates,3200, :order => :distance)
    end
    
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
   	   @passes = @user.passes.order('updated_at DESC')
   	end
  end

end
