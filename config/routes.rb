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
  get "pages/terms_of_service"
  get "pages/customers"
  get "pages/contact_us"
  get "pages/privacy_policy"
  get "pages/about_us"
  get "pages/download"
  match "purchases/purchase_history" => 'purchases#purchase_history'
  match '/businesspdf' => 'pages#download'
  match '/pdfversion' => 'passes#pdfversion'

  match 'contact' => 'contact#new', :as => 'contact', :via => :get
match 'contact' => 'contact#create', :as => 'contact', :via => :post
	resources :bars do
  	resources :pass_sets
    collection do
      post 'search'
			end
		end
  resources :admin
  resources :passes
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
	
resources :tokens,:only => [:create, :destroy]


end