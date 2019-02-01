module Mautic
  # Represent received web hook
  class WebHook

    attr_reader :connection
    # @param [Mautic::Connection] connection
    # @param [ActionController::Parameters] params
    def initialize(connection, params)
      @connection = connection
      @params = params
    end

    def form_submissions
      @forms ||= Array.wrap(@params.require("mautic.form_on_submit")).collect do |data|
        p = data.permit(submission: [:id, form: {}, lead: {}]).to_h
        ::Mautic::Submissions::Form.new(@connection, p["submission"]) if p["submission"]
      end.compact
    end

  end
end