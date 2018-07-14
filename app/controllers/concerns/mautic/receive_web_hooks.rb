module Mautic
  module ReceiveWebHooks
    extend ActiveSupport::Concern

    included do

    end

    protected

    # params path need +:mautic_id+
    def webhook
      @webhook ||= Mautic::Connection.receive_webhook params
    end
  end
end