Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    delete 'logout', to: 'users/sessions#destroy', as: :logout
    post 'login', to: 'users/sessions#create', as: :login
    get 'login', to: 'users/sessions#new'
  end

  resources :planetary_commodities, only: %i[index show] do
    post :update_prices, on: :collection
  end

  scope '', controller: :pages do
    get :character_data
  end

  root 'pages#dashboard'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
