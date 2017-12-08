module Mautic
  class Connection < ApplicationRecord

    self.table_name = 'mautic_connections'

    validates :url, :client_id, :secret, presence: true
    validates :url, format: URI::regexp(%w(http https))

    alias_attribute :access_token, :token

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

    def request(type, path, params = {})
      @last_request = [type, path, params]
      response = raise NotImplementedError
      parse_response(response)
    end

    private

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
