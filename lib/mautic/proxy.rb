module Mautic
  class Proxy

    def initialize(connection, endpoint, options = nil)
      @options = options || {}
      @connection = connection
      klass = @options.delete(:klass) || "Mautic::#{endpoint.classify}"
      @target = klass.safe_constantize || Mautic.const_set(endpoint.classify, Class.new(Mautic::Model))
      @endpoint = endpoint
    end

    def new(attributes = {})
      build_instance attributes
    end

    def data_name
      @options[:data_name] || @endpoint.split("/").last
    end

    def build_instance(data)
      @target.new(@connection, data)
    end

    def all(options = {}, &block)
      if options[:limit] == 'all'
        options.delete(:limit)
        limit_all(options, &block)
      else
        results = where(options)
        results.each { |i| yield i } if block_given?
        results
      end
    end

    # @param [Hash] params
    # @see https://developer.mautic.org
    def where(params = {})
      q = params.reverse_merge(@options[:default_params] || {})
      json = @connection.request(:get, "api/#{@endpoint}", params: q)
      @count = json["total"].to_i
      @last_response = json
      json[data_name].collect do |id, attributes|
        build_instance attributes || id
      end
    end

    def first
      where(limit: 1).first
    end

    def find(id)
      json = @connection.request(:get, "api/#{@endpoint}/#{id}")
      @last_response = json
      build_instance json[data_name.singularize]
    end

    def count
      return @count if defined? @count

      json = @connection.request(:get, "api/#{@endpoint}", { limit: 1 })
      @count = json["total"].to_i
    end

    protected

    # @param [Hash] options
    # @option options (see #where)
    def limit_all(options, &block)
      records = results = where(options)
      total = @last_response['total'].to_i
      while records.any?
        records.each(&block) if block_given?
        break if results.size >= total

        records = where(options.merge(start: records.size))
        results.concat records
      end
      results
    end

  end
end
