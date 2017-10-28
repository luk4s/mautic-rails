Mautic::Engine.routes.draw do
  resources :connections do
    member do
      get :authorize
      get :oauth2

    end
  end
end
