Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    delete 'logout', to: 'users/sessions#destroy', as: :logout
    post 'login', to: 'users/sessions#create', as: :login
    get 'login', to: 'users/sessions#new'
  end

  namespace :industry do
    get :jobs
    post :update_jobs
  end

  resources :market_orders, only: %i[index] do
    post :update_all, on: :collection
  end

  resources :planetary_colonies, only: %i[index] do
    post :update, on: :collection, as: :update
  end

  resources :planetary_commodities, only: %i[index show] do
    post :update_prices, on: :collection
  end

  scope '', controller: :pages do
    get :character_data
  end

  get 'settings', to: 'users#settings'
  delete 'remove_character(/:id)', to: 'users#remove_character', as: :remove_character

  root 'pages#dashboard'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
