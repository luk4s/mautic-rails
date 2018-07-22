module Mautic
  class Connection < ApplicationRecord

    self.table_name = 'mautic_connections'

    validates :url, presence: true, format: URI::regexp(%w(http https))
    validates :client_id, :secret, presence: true, unless: :new_record?

    alias_attribute :access_token, :token

    # @param [ActionController::Parameters] params
    def self.receive_webhook(params)
      WebHook.new(find(params.require(:mautic_id)), params)
    end

    def client
      raise NotImplementedError
    end

    def authorize
      raise NotImplementedError
    end

    def get_code(code)
      raise NotImplementedError
    end

    def connection
      raise NotImplementedError
    end

    def refresh!
      raise NotImplementedError
    end

    %w(assets campaigns categories companies emails forms messages notes notifications pages points roles stats users).each do |entity|
      define_method entity do
        Proxy.new(self, entity)
      end
    end

    def contacts
      Proxy.new(self, 'contacts', default_params: { search: '!is:anonymous' })
    end

    def tags
      Proxy.new(self, 'tags')
    end

    def request(type, path, params = {})
      @last_request = [type, path, params]
      response = raise NotImplementedError
      parse_response(response)
    end

    private

    def callback_url
      if (conf = Mautic.config.base_url).is_a?(Proc)
        conf = conf.call(self)
      end

      URI.parse(conf)
    end

    def parse_response(response)
      case response.status
      when 400
        raise Mautic::ValidationError.new(response)
      when 404
        raise Mautic::RecordNotFound.new(response)
      when 200, 201
        json = JSON.parse(response.body) rescue {}
        Array(json['errors']).each do |error|
          case error['code'].to_i
          when 401
            raise Mautic::TokenExpiredError.new(response) if @try_to_refresh
            @try_to_refresh = true
            refresh!
            json = request(*@last_request)
          when 404
            raise Mautic::RecordNotFound.new(response)
          else
            raise Mautic::RequestError.new(response)
          end
        end
      else
        raise Mautic::RequestError.new(response)
      end

      json
    end

  end
end
