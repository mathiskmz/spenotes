Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
  get "listen", to: "pages#listen", as: :listen

  resources :patients do
    resource :bilan, only: [ :new, :create, :edit, :update, :show ] do
      delete :remove_file, on: :member
      get  :recording, on: :member
      post :upload_chunk, on: :member
      post :add_manual_note, on: :member
      post :finalize, on: :member
    end
    resources :notes, only: [ :new, :create ]
    member do
      post :add_files
      delete :remove_file
    end
  end

  resources :notes, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    member do
      post :add_files
      delete :remove_file
    end
  end

  resources :vocabularies, only: [ :index, :create, :destroy ]

  resource :settings, only: [ :show, :update ]
end
