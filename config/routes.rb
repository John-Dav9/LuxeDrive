Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  
  # Page d'accueil personnalisée
  root to: "pages#home"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest.json" => "rails/pwa#manifest", as: :pwa_manifest

  # Super Admin
  namespace :super_admin do
    root to: 'dashboard#index'
    resources :users do
      member do
        patch :change_role
      end
    end
    resources :cars, only: [:index, :edit, :update, :destroy] do
      delete "photos/:photo_id", to: "cars#destroy_photo", as: :photo
    end
    resources :bookings, only: [:index]
    resource :contract_setting, only: [:edit, :update]
    resources :owner_requests, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
        patch :needs_contract
        post :send_contract
      end
    end
  end

  # Owner
  namespace :owner do
    root to: "dashboard#index"
    resources :cars, only: [:index, :edit, :update, :destroy] do
      delete "photos/:photo_id", to: "cars#destroy_photo", as: :photo
    end
    resources :bookings, only: [:index]
    get "documents", to: "documents#index"
    get "documents/download_all", to: "documents#download_all", as: :documents_download_all
  end

  # Voitures avec réservations imbriquées
  resources :cars do
    delete "photos/:photo_id", to: "cars#destroy_photo", as: :photo
    resources :bookings, only: [:new, :create]
  end

  # Réservations
  resources :bookings, only: [:index, :show] do
    member do
      patch :accept
      patch :reject
      patch :cancel
      get :payment
      post :start_payment
      get :payment_success
      get :payment_cancel
      get :payment_intent_success
      get :payment_failed
      post :paypal_create
      post :paypal_capture
    end
  end

  post "webhooks/stripe", to: "stripe_webhooks#create"
  post "webhooks/paypal", to: "paypal_webhooks#create"

  # Dashboard utilisateur
  get 'dashboard', to: 'pages#dashboard'
  resources :notifications, only: [:index] do
    member do
      patch :read
    end
  end
  get "contrat_prestataire", to: "contracts#provider", as: :provider_contract
  resource :owner_request, only: [:new, :create, :show, :edit, :update]
  # Legacy owner pages (kept for compatibility via redirect in controller)
  get 'owner_dashboard', to: 'pages#owner_dashboard'
  get 'about', to: 'pages#about'
  get 'legal', to: 'pages#legal'
  get 'privacy', to: 'pages#privacy'
  get 'cookies', to: 'pages#cookies'
  get 'mentions_legales', to: 'pages#mentions_legales'
  get 'faq', to: 'pages#faq'
  get 'pricing', to: 'pages#pricing'
  get 'owner_guide', to: 'pages#owner_guide'
  
  # Browse cars (alias)
  get 'browse', to: 'cars#index', as: :browse_cars
end
