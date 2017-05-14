Hvz::Application.routes.draw do
  get "check_ins" => "check_ins#index"
  get "check_ins/new", :as => "check_in_wizard"
  get "check_ins/create", :as => "check_in"
  get "feeds/create"

  # The priority is based upon order of creation:
  # first created -> highest priority.
  match "/people/login/", to: "people#login", via: :all
  match "/people/logout/", to: "people#logout", via: :all
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
      get 'tools'
      get 'rules'
      get 'tree'
      get 'heatmap'
      get 'emails'
      get 'text'
      post 'text' => 'games#text_create'
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

  match "squads/:id", to: "squad#show", as: "squad", via: :all
  match "squads", to: "squad#index", as: "squads", via: :all
  match "players/:id/joinsquad/:squadid", to: "registrations#joinsquad", as: "join_squad", via: :all

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "index#root"

  # See how all your routes lay out with "rake routes"
end
