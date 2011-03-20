Hvz::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  	match "/people/login/" => "people#login"
  	match "/people/logout/" => "people#logout"
	resources :people, :games, :tags
	resources :players, :as => :registrations, :controller => :registrations do
		resources :infractions
	end
	match "/players/:id/submitwaiver/:has" => "registrations#submit_waiver", :as => "submit_waiver"
	match 'games/:id/rules' => "games#rules", :as => "game_rules"
	match "/contact/" => "contact_messages#new", :as=>"contact_messages", :via => "get"
	match "/contact/" => "contact_messages#create", :as => "new_contact_message",:via => "post"
	match "/contact/list(/:all)" => "contact_messages#list", :as => "list_contact_messages", :via=>"get"
	match "/contact/:id" => "contact_messages#destroy", :as => "delete_contact_message", :via=>"delete"
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
