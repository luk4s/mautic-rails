Rails.application.routes.draw do
  mount Mautic::Engine => "/mautic"
end
