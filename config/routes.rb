Mautic::Engine.routes.draw do
  resources :connections do
    member do
      get :authorize
      get :oauth2

    end
    # post "webhook/:mautic_id", action: "webhook", on: :collection
  end
end
