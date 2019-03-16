module Mautic
  module ReceiveWebHooks
    extend ActiveSupport::Concern

    included do

    end

    protected

    # @note params path need +:mautic_connection_id+ . => Its Mautic::Connection ID
    def webhook
      @webhook ||= Mautic::Connection.receive_webhook params
    end
  end
end