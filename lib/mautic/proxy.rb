module Mautic
  class Proxy
    # attr_reader :connection, :target

    def initialize(connection, endpoint)
      @mautic_connection = connection
      @connection = @mautic_connection.connection
      klass = "Mautic#{endpoint.classify}"
      @target = klass.safe_constantize || Object.const_set(klass, Class.new(Mautic::Model))
      @endpoint = endpoint
    end

    def all
      where
    end

    def where(arg = '')
      params = case arg
               when ::String
                 { search: arg } if arg.present?
               when ::Hash
                 arg
               end
      json = request(:get, "api/#{@endpoint}", { params: params })
      json[@endpoint].collect do |_id, attributes|
        @target.new(self, attributes)
      end
    end

    def first
      where(limit: 1).first
    end

    def find(id)
      json = request(:get, "api/#{@endpoint}/#{id}")
      @target.new(self, json[@endpoint.singularize])
    end

    def request(type, path, params = {})
      json = JSON.parse @connection.request(type, path, params).body
      Array(json['errors']).each do |error|
        case error['code']
        when 401
          raise Mautic::TokenExpiredError.new(error['message']) if @try_to_refresh
          @try_to_refresh = true
          @connection = @mautic_connection.refresh!
          json = request(type, path, params)
        else
          raise AuthorizeError.new("#{error['code']} - #{error['message']}")
        end
      end
      json
    end


  end
end