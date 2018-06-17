module Mautic
  # Represent received web hook
  class WebHook

    # @param [Mautc::Connection] connection
    # @param [ActionController::Parameters] params
    def initialize(connection, params)
      @connection = connection
      @params = params
    end

    def form_submission
      @form ||= @params.require("mautic.form_on_submit")
    end
  end
end