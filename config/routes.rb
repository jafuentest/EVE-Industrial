Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  root 'pages#spa'

  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    delete 'logout', to: 'users/sessions#destroy', as: :logout
    post 'login', to: 'users/sessions#create', as: :login
    get 'login', to: 'users/sessions#new'
  end

  namespace :api do
    scope module: :v1 do
      resource :session, only: %i[show destroy]
      resource :counts, only: %i[show]
      resource :sync, only: %i[create]

      resources :industry_jobs, only: %i[index] do
        post :update, on: :collection
      end

      resources :market_orders, only: %i[index]

      resources :planetary_colonies, only: %i[index] do
        post :update, on: :collection
      end

      resources :planetary_commodities, only: %i[index show] do
        post :update, on: :collection
      end

      resources :characters, only: %i[index destroy]
    end
  end

  get '*path', to: 'pages#spa', constraints: ->(req) { req.format.html? }
end
