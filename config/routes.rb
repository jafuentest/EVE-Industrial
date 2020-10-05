Rails.application.routes.draw do
  resources :planetary_commodities, only: %i[index show] do
    post :update_prices, on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
