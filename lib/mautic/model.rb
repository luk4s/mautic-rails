module Mautic
  class Model < OpenStruct

    class MauticHash < Hash

      def []=(name, value)
        @changes ||= {}
        @changes[name] = value
        super
      end

      def changes
        @changes || {}
      end

    end

    class << self

      def endpoint
        name.demodulize.underscore.pluralize
      end

      def in(connection)
        Proxy.new(connection, endpoint)
      end

    end

    def initialize(connection, hash=nil)
      @connection = connection
      @table = MauticHash.new
      self.attributes = { created_at: hash['dateAdded']&.to_time, updated_at: hash['dateModified']&.to_time } if hash
      assign_attributes(hash)
    end

    def save(force = false)
      id.present? ? update(force) : create
    end

    def update(force = false)
      return false if changes.blank?
      json = @connection.request((force && :put || :patch), "api/#{endpoint}/#{id}/edit", { body: to_h })
      if json['errors']
        self.errors = json['errors']
      else
        self.attributes = json[endpoint.singularize]
      end
      json['errors'].blank?
    end

    def create
      json = @connection.request(:post, "api/#{endpoint}/#{id}/new", { body: to_h })
      if json['errors']
        self.errors = json['errors']
      else
        self.attributes = json[endpoint.singularize]
      end
      json['errors'].blank?
    end

    def destroy
      json = @connection.request(:delete, "api/#{endpoint}/#{id}/delete")
      self.errors = json['errors'] if json['errors']
      json['errors'].blank?
    end

    def changes
      @table.changes
    end

    def attributes
      @table.to_h
    end

    private

    def endpoint
      self.class.endpoint
    end

    def attributes=(hash)
      hash.each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
      end
      @table.instance_variable_set(:@changes, nil)
    end

    def assign_attributes(source = nil)
      source ||= {}
      data = {}
      if (fields = source['fields'])
        data.merge!(fields['all']) if fields['all']
      elsif source
        data = source
      end
      self.attributes = data
    end

  end
end