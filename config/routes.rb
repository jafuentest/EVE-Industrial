EVEIndustrial::Application.routes.draw do
  root :to => 'static_pages#home'
  
  match 'spreadsheets/ice_mining' => 'spreadsheets#ice_mining', via: [:get, :post]
  match 'spreadsheets/ore_mining' => 'spreadsheets#ore_mining', via: [:get, :post]
  match 'spreadsheets/planetary_interaction' => 'spreadsheets#planetary_interaction', via: [:get, :post]
  match 'spreadsheets/refining' => 'spreadsheets#refining', via: [:get, :post]
  match 'static_pages/home' => 'static_pages#home', via: [:get]
  
  resources :ice_yields, only: [:index]
  resources :yields, only: [:index]
  resources :schematics, only: [:index]
  resources :ice_products, except: [:create, :new, :destroy]
  resources :ores, except: [:create, :new, :destroy]
  resources :planetary_commodities, except: [:create, :new, :destroy]
  resources :systems, except: [:create, :new, :destroy]
  
  resources :regions, except: [:create, :new, :destroy] do
    resources :systems
  end
  
  resources :minerals, except: [:create, :new, :destroy]  do
    collection do
      get 'check_eve_central_ids'
    end
  end
  
  resources :ice_ores, except: [:create, :new, :destroy] do
    member do
      get  'add_yields'
      post 'add_yields'
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
