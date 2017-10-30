module Mautic
  class Proxy

    def initialize(connection, endpoint)
      @connection = connection
      klass = "Mautic::#{endpoint.classify}"
      @target = klass.safe_constantize || Mautic.const_set(endpoint.classify, Class.new(Mautic::Model))
      @endpoint = endpoint
    end

    def new(attributes = {})
      @target.new(@connection, attributes)
    end

    def all(options={})
      where(options)
    end

    def where(arg = '')
      params = case arg
               when ::String
                 { search: arg } if arg.present?
               when ::Hash
                 arg
               end
      json = @connection.request(:get, "api/#{@endpoint}", { params: params })
      json[@endpoint].collect do |id, attributes|
        @target.new(@connection, attributes || id)
      end
    end

    def first
      where(limit: 1).first
    end

    def find(id)
      json = @connection.request(:get, "api/#{@endpoint}/#{id}")
      @target.new(@connection, json[@endpoint.singularize])
    end


  end
end