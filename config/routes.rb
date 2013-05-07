ListdApp::Application.routes.draw do
  resources :events


  resources :tickets


  resources :reservations


  resources :deals


  resources :ticket_sets


  resources :reservation_sets


  resources :deal_sets


  resources :fechas


  resources :dia


  resources :locations


  get "current_user/update"
  match "current_user/delete_stripe_token" => 'current_user#delete_stripe_token'
  match '/activity_feed' => 'pages#facebook_activity'
  post "users/setPartner"
  match '/payment_management' => 'current_user#update'
  match 'welcome' => 'home#welcome'
  post "users/unsetPartner"
  post "passes/toggleRedeem"
  post "tickets/toggleRedeem"
  post "deals/toggleRedeem"
  post "reservations/toggleRedeem"
  get "admin/customers"
  get "admin/partners"
  get "pages/terms_of_service"
  get "pages/customers"
  get "pages/contact_us"
  get "pages/privacy_policy"
  get "pages/about_us"
  get "pages/download"
  match "purchases/purchase_history" => 'purchases#purchase_history'
  match '/businesspdf' => 'pages#download'
  match '/pdfversion' => 'passes#pdfversion'
  match '/pdfticketversion' => 'tickets#pdfversion'
  match '/pdfdealversion' => 'deals#pdfversion'
  match '/pdfreservationversion' => 'reservations#pdfversion'

  match 'contact' => 'contact#new', :as => 'contact', :via => :get
  match 'contact' => 'contact#create', :as => 'contact', :via => :post
	
	resources :bars do
  	resources :pass_sets
    collection do
      post 'search'
		end
	end
	
  resources :locations do
    resources :ticket_sets
    collection do
      post 'search'
    end
    resources :pass_sets
    collection do
      post 'search'
    end
    resources :deal_sets
    collection do
      post 'search'
    end
    resources :reservation_sets
    collection do
      post 'search'
    end
  end
  
  resources :events do
    resources :ticket_sets
    collection do
      post 'search'
    end
    resources :pass_sets
    collection do
      post 'search'
    end
    resources :deal_sets
    collection do
      post 'search'
    end
    resources :reservation_sets
    collection do
      post 'search'
    end
  end
  
  resources :admin
  resources :passes
  match '/mypasses' => 'passes#index'
  match '/mytickets' => 'tickets#index'
  match '/mydeals' => 'deals#index'
  match '/myreservations' => 'reservations#index'
  
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
		end
	end
	
	resources :users do
	  resources :bars do
  	  resources :pass_sets do
          get 'close_set'
      end
		end
	end
	
	resources :users do
	  resources :locations do
	    resources :ticket_sets do
	      get 'close_set'
	    end
	    resources :fecha do
	    end
	    resources :pass_sets do
	      get 'close_set'
	    end
	    resources :deal_sets do
	      get 'close_set'
	    end
	    resources :reservation_sets do
	      get 'close_set'
	    end
	  end
	end
	
	resources :users do
	  resources :events do
	    resources :ticket_sets do
	      get 'close_set'
	    end
	    resources :fecha do
	    end
	    resources :pass_sets do
	      get 'close_set'
	    end
	    resources :deal_sets do
	      get 'close_set'
	    end
	    resources :reservation_sets do
	      get 'close_set'
	    end
	  end
	end
	
	resources :users do
	  resources :bars do
  	  resources :ticket_sets do
          get 'close_set'
      end
		end
	end
	
	resources :users do
	  resources :bars do
  	  resources :fechas do
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
    end
  end

end