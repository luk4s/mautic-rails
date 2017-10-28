require "oauth2"
require "mautic/engine"

module Mautic
  include ::ActiveSupport::Configurable

  configure do |config|
    config.base_url = "http://localhost:3000"
  end
  # Your code goes here...
end
