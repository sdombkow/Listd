ListdApp::Application.routes.draw do
    get "current_user/update"
    match "current_user/delete_stripe_token" => 'current_user#delete_stripe_token'
    match '/activity_feed' => 'pages#facebook_activity'
    post "users/setPartner"
    match '/payment_management' => 'current_user#update'
    match 'welcome' => 'home#welcome'
    post "users/unsetPartner"
    get "passes/toggleRedeem"
    get "admin/customers"
    get "admin/partners"
    get "pages/terms_of_service"
    get "pages/customers"
    get "pages/contact_us"
    get "pages/privacy_policy"
    get "pages/about_us"
    get "pages/download"
    get "pages/dashboard_temp"
    get "pages/edit_pass_set_temp"
    match "purchases/purchase_history" => 'purchases#purchase_history'
    match '/businesspdf' => 'pages#download'
    match '/pdfversion' => 'passes#pdfversion'
    match '/pdfversionweekly' => 'weekly_passes#pdfversion'
    match '/weeklypasstoggleredeem' => 'weekly_passes#toggleRedeem'
    match '/qrcode' => 'passes#mobile_code'
    match '/qrcodeweekly' => 'weekly_passes#mobile_code'
    match 'contact' => 'contact#new', :as => 'contact', :via => :get
    match 'contact' => 'contact#create', :as => 'contact', :via => :post
    
	  resources :bars do
  	    resources :pass_sets
        collection do
            post 'search'
		    end
		    resources :week_passes
	  end
	  
    resources :admin
    resources :passes
    resources :weekly_passes
    match '/mypasses' => 'passes#index'
    match '/myreservations' => 'passes#reservation_archive'
    match '/myweeklypasses' => 'weekly_passes#index'
  
    resources :purchases do
  	    collection do
  		      get 'createpurchase'
  	    end
    end

    authenticated :user do
        root :to => 'home#welcome'
    end
    
    root :to => "home#index"
    devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  
    resources :users do
	      resources :bars do
  	        resources :pass_sets
            collection do
                post 'search'
			      end
			      resources :week_passes
		    end
	  end
	
	  resources :users do
	      resources :bars do
  	        resources :pass_sets do
                get 'close_set'
            end
            resources :week_passes do
                get 'close_set'
            end
		    end
	  end
	
    resources :tokens,:only => [:create, :destroy]
    
    namespace :api do
        namespace :v1 do
            devise_scope :user do
                post 'registrations' => 'registrations#create', :as => 'register'
                post 'sessions' => 'sessions#create', :as => 'login'
                delete 'sessions' => 'sessions#destroy', :as => 'logout'
            end
            get 'tasks' => 'tasks#index', :as => 'tasks'
	          post 'search' => 'tasks#search', :as => 'search'
            get 'check_mobile_login' => 'tasks#check_mobile_login', :as => 'check_mobile_login'
	          post 'passset' => 'tasks#passset', :as => 'passset'
	  	      post 'purchase' => 'tasks#purchase', :as => 'purchase'
		  	    get 'passes' => 'tasks#passes', :as => 'passes'
        end
    end
end