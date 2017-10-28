Mautic::Engine.routes.draw do
  resources :mautic_connections do
    member do
      get :authorize
      get :oauth2

    end
  end
end
