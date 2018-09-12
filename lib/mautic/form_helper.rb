require 'net/https'

module Mautic
  class NetworkError < StandardError; end

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

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.set_form_data(data)
      @response = perform_request(configure_http(uri), request)
    end
    alias_method :push, :submit

    private

    def configure_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      if Gem.win_platform?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths
        http.cert_store = cert_store
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http
    end

    def perform_request(http, request)
      response = nil
      begin
        response = http.request(request)
      rescue => e
        raise Mautic::NetworkError, e
      end
      if response.code.to_i >= 400
        raise Mautic::NetworkError, "#{response.code} #{response.msg}"
      end
      response
    end
  end

end