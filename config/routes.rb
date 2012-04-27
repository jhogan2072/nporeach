class MainSite
  def self.matches?(request)
    request.subdomain.blank? || request.subdomain == 'www'
  end
end

Conservatory::Application.routes.draw do

  resources :import_tables

  get "csv/import"
  post "csv/import" => 'csv#upload'

  namespace :admin do 
    resources :menu_items do
      collection do
        get :add_child
      end
    end
  end

  match '/autocomplete/users' => "autocomplete#users"

  resources :assignments
  resources :roles
  resources :portlets
  resources :portlet_categories
  match '/users/columns' => 'users#columns'
  match '/users/update_columns' => 'users#update_columns'
  match '/accounts/settings' => 'accounts#settings'
  match '/accounts/update_settings' => 'accounts#update_settings'
  match 'message' => 'message#new', :as => 'message', :via => :get
  match 'message' => 'message#create', :as => 'message', :via => :post

  # Routes for the public site
  constraints MainSite do
    # Homepage
    root :to => "content#index"
    
    # Account Signup Routes
    match '/signup' => 'accounts#plans', :as => 'plans'
    match '/signup/d/:discount' => 'accounts#plans'
    match '/signup/thanks' => 'accounts#thanks', :as => 'thanks'
    match '/signup/create/:discount' => 'accounts#create', :as => 'create', :defaults => { :discount => nil }
    match '/signup/:plan/:discount' => 'accounts#new', :as => 'new_account'
    match '/signup/:plan' => 'accounts#new', :as => 'new_account'

    # Account login route - retrieve site address
    match '/login' => 'accounts#siteaddress', :as => 'login'
    match '/loginredirect' => 'accounts#loginredirect'

    # Catch-all that just loads views from app/views/content/* ...
    # e.g, http://yoursite.com/content/about -> app/views/content/about.html.erb
    #
    match '/content/:action' => 'content'
  end

  root :to => "users#dashboard"
  devise_for :users

  #
  # Account / User Management Routes
  #
  resources :users, :except => :show do
    member do
      match :update_mylinks, :dashboard, :remove_help
    end
    collection do
      get :print
      get :profile
      get :password
      get :credentials
      get :message
    end
  end
  
  resources :families, :except => :show do
    member do
      match 'members'
    end
    collection do
      get :my_family
    end
  end

  resource :account do 
    member do
      get :thanks, :plans, :canceled
      match :billing, :paypal, :plan, :plan_paypal, :cancel, :change_owner
    end
  end

  # Administrative routes
  devise_for :admins

  namespace "admin" do

    root :to => "subscriptions#index"
    match '/privileges/update_actions', :controller=>'privileges', :action => 'update_actions'
    
    resources :subscriptions do
      member do
        post :charge
      end
    end

    resources :settings
    resources :privileges
    resources :default_roles
    resources :accounts
    resources :subscription_plans, :path => 'plans'
    resources :subscription_discounts, :path => 'discounts'
    resources :subscription_affiliates, :path => 'affiliates'
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
