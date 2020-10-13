Rails.application.routes.draw do
  devise_scope :user do
    get 'logout', to: 'users/sessions#destroy', as: :logout
    get 'login', to: 'users/sessions#create', as: :login
  end

  resources :planetary_commodities, only: %i[index show] do
    post :update_prices, on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
