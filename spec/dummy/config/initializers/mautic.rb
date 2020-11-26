Mautic.configure do |config|
  config.authorize_mautic_connections = lambda do |controller|
    controller.request.url.start_with? "http://localhost:3000"
  end
end