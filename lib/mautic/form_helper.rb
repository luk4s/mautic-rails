require 'rest-client'
module Mautic
  class FormHelper

    # shortcut
    def self.submit(url: nil, form: nil, request: nil, &block)
      m = new(url || Mautic.config.mautic_url, request)
      m.send_data form, &block
    end

    attr_reader :url, :host
    attr_accessor :forward_ip
    attr_writer :data

    def initialize(url, request = nil)
      @url = url

      @host = request&.host
      @forward_ip = request&.remote_ip
    end

    def send_data(form_id, &block)
      @collector = OpenStruct.new(formId: form_id)
      yield @collector
      self.data = @collector.to_h

      push
    end

    def data
      raise ArgumentError if @data.nil?
      defaults = {
        'submit' => '1',
        'return' => host,
        'domain' => host
      }
      defaults.merge(@data.to_h).inject({}){|mem, (name, value)| mem["mauticform[#{name}]"] = value; mem}
    end

    def submit
      uri = URI.parse(url)
      uri.path = '/form/submit'
      headers = {}
      headers.store 'X-Forwarded-For', forward_ip if forward_ip
      begin
        @response = RestClient.post uri.to_s, data, headers
      rescue RestClient::Found => e
        @response = e
      end

    end
    alias_method :push, :submit
  end

end