Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root to: "pages#home"
  get "about", to: "pages#about"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :weeks, only: [:create, :new, :show] do
    resources :days, only: [:show, :create, :destroy]
    resources :shopping_items, only: [:index]
  end
  resources :dishes, only: [:show, :create, :update, :destroy]

  resources :shopping_items, only: [:update]
  resources :recipes, only: [:show]

  resources :favorites, only: [:index, :create, :destroy] do
    get :toggle, on: :collection
  end

  get "/settings", to: "users#settings", as: :settings
  patch "/settings", to: "users#update_settings"
end
