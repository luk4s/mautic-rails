module Mautic
  class Engine < ::Rails::Engine
    isolate_namespace Mautic

    config.generators do |g|
      g.test_framework :rspec, fixture: false
    end
  end
end
