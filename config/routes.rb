Rails.application.routes.draw do
  resources :tasks
  resources :addresses do
  member do
    get :confirm_delete
  end
end
  resources :regions
  resources :cities
  get "recycle_bin" => "recycle_bin#index", as: :recycle_bin
  post "recycle_bin/:id/restore" => "recycle_bin#restore", as: :restore_recycle_bin
  get "sign_in" => "sessions#new", as: :sign_in
  post "sign_in" => "sessions#create"
  get "create_account" => "accounts#new", as: :create_account
  post "create_account" => "accounts#create"
  delete "sign_out" => "sessions#destroy", as: :sign_out
  get "sign_out" => "sessions#destroy", as: :get_sign_out
  get "user" => "users#show", as: :user
  patch "user" => "users#update"
  root "sessions#new"
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
