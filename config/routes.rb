Hvz::Application.routes.draw do
  get "check_ins" => "check_ins#index"
  get "check_ins/new", :as => "check_in_wizard"
  get "check_ins/create", :as => "check_in"
  get "feeds/create"

  # The priority is based upon order of creation:
  # first created -> highest priority.
  	match "/people/login/" => "people#login"
  	match "/people/logout/" => "people#logout"
	resources :people, :tags, :feeds
	resources :attendances
  get "bonus_codes/claim" => "bonus_codes#claim", :as => "claim_bonus_code"
  put "bonus_codes/claim" => "bonus_codes#claim_submit", :as => "submit_bonus_code"
  resources :bonus_codes
  resources :missions, :id => /[0-9]*/ do
    collection do
      get :autocomplete_person_name
      get 'list'
    end

    member do
      get 'attendance'
      get 'feeds'
      get 'points'
      post 'points' => 'missions#save_points'
    end
  end
	resources :players, :as => :registrations, :controller => :registrations, :id=>/[0-9]*/ do
      get 'showwaiver'
		resources :infractions
	end
  match '/players/find_by_code/' => 'registrations#find_by_code', :as => 'find_registration_by_code', :via => 'get'
  get 'players/:id/waiver' => "waiver#new", :as => "sign_waiver"
  post 'players/:id/waiver' => "waiver#create", :as => "waivers"

  resources :games do
    collection do
      post 'update_current'
    end

    member do
      get 'rules'
      get 'tree'
      get 'heatmap'
      get 'emails'
      get 'admin_register' => 'games#admin_register_new'
      post 'admin_register' => 'games#admin_register_create'
    end
  end

  get '/contact' => 'contact_messages#new'
	resources :contact, :as => :contact_messages, :controller => :contact_messages do
		collection do
			get :list
		end
	end

  match "squads/:id" => "squad#show", :as=> "squad"
  match "squads" => "squad#index", :as=> "squads"
  match "players/:id/joinsquad/:squadid" => "registrations#joinsquad", :as => "join_squad"

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
  root :to => "index#root"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
