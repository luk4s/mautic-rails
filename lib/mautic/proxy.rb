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

    def all(options = {})
      if options[:limit] == 'all'

        options.delete(:limit)

        records = results = where(options)
        per_page = results.size.to_f
        total = @last_response['total'].to_i

        return results if per_page >= total && !block_given?
        ((total - per_page) / per_page).ceil.times do |i|
          if block_given?
            records.each {|record| yield record }
          end
          c = (per_page * (i + 1))
          records = where(options.merge(start: c.to_i))
          results.concat records
        end

        results
      else
        where(options)
      end
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