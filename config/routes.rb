ListdApp::Application.routes.draw do
  get "current_user/update"
  match "current_user/delete_stripe_token" => 'current_user#delete_stripe_token'
  match '/activity_feed' => 'pages#facebook_activity'
  post "users/setPartner"
  match '/payment_management' => 'current_user#update'
  match 'welcome' => 'home#welcome'
  post "users/unsetPartner"
  post "passes/toggleRedeem"
  get "admin/customers"
  get "admin/partners"
	resources :bars do
  	resources :pass_sets
    collection do
      post 'search'
			end
		end
  resources :admin
  get "passes/index"
  match '/mypasses' => 'passes#index'
  
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
	
end