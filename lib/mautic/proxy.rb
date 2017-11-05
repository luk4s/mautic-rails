module Mautic
  class Proxy

    def initialize(connection, endpoint, options = nil)
      @connection = connection
      klass = "Mautic::#{endpoint.classify}"
      @target = klass.safe_constantize || Mautic.const_set(endpoint.classify, Class.new(Mautic::Model))
      @endpoint = endpoint
      @options = options || {}
    end

    def new(attributes = {})
      @target.new(@connection, attributes)
    end

    def all(options = {}, &block)
      if options[:limit] == 'all'

        options.delete(:limit)

        records = results = where(options)
        total = @last_response['total'].to_i
        while records.any?
          if block_given?
            records.each &block
          end
          break if results.size >= total

          records = where(options.merge(start: records.size))
          results.concat records
        end
      else
        results = where(options)
        results.each{|i| yield i } if block_given?
      end
      results
    end

    def where(params = {})
      q =  params.reverse_merge(@options[:default_params] || {})
      json = @connection.request(:get, "api/#{@endpoint}", {params: q })
      @last_response = json
      json[@endpoint].collect do |id, attributes|
        @target.new(@connection, attributes || id)
      end
    end

    def first
      where(limit: 1).first
    end

    def find(id)
      json = @connection.request(:get, "api/#{@endpoint}/#{id}")
      @last_response = json
      @target.new(@connection, json[@endpoint.singularize])
    end


  end
end