Rails.application.routes.draw do
  mount Mautic::Engine => "/mautic"
  root to: "mautic/connections#index", controller: "Mautic::ConnectionsController"
end
