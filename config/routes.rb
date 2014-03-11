EVEIndustrial::Application.routes.draw do
  root :to => 'static_pages#home'
  
  match 'static_pages/home' => 'static_pages#home', via: [:get]
  
  match '/login' => 'sessions#new', via: [:get, :post]
  match '/logout' => 'sessions#destroy', via: [:get]
  
  match 'spreadsheets/ice_mining' => 'spreadsheets#ice_mining', via: [:get, :post]
  match 'spreadsheets/ore_mining' => 'spreadsheets#ore_mining', via: [:get, :post]
  match 'spreadsheets/planetary_interaction' => 'spreadsheets#planetary_interaction', via: [:get, :post]
  match 'spreadsheets/refining' => 'spreadsheets#refining', via: [:get, :post]
  
  resources :users
  resources :ice_yields, only: [:index]
  resources :schematics, only: [:index]
  resources :yields, only: [:index]
  resources :ores, except: [:create, :new, :destroy]
  resources :sessions, only: [:create, :new, :destroy]
  resources :systems, except: [:create, :new, :destroy]
  
  resources :regions, except: [:create, :new, :destroy] do
    resources :systems, only: [:index]
  end
  
  resources :ice_products, except: [:create, :new, :destroy]  do
    collection do
      get 'check_central_ids'
    end
  end
  
  resources :ice_ores, except: [:create, :new, :destroy] do
    collection do
      get 'check_central_ids'
    end
    member do
      get  'add_yields'
      post 'add_yields'
    end
  end
  
  resources :minerals, except: [:create, :new, :destroy]  do
    collection do
      get 'check_central_ids'
    end
  end
  
  resources :planetary_commodities, except: [:create, :new, :destroy]  do
    collection do
      get 'check_central_ids'
    end
  end
  
  resources :variations, except: [:create, :new, :destroy]  do
    collection do
      get 'check_central_ids'
    end
    member do
      get  'add_yields'
      post 'add_yields'
    end
  end
end
