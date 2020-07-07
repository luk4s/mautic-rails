module Mautic
  class ConnectionsController < ApplicationController
    before_action :authorize_me
    include ::Mautic::ConnectionsControllerConcern

    private

    def authorize_me
      unless Mautic.config.authorize_mautic_connections.call(self)
        logger.warn "Mautic::ConnectionsController unauthorized, you can change this by Mautic.config.authorize_mautic_connections. See: lib/mautic.rb:77"
        render plain: "Unauthorized", status: 403
      end
    end
  end
end
