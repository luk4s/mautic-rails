module Mautic
  # Virtual model for Mautic endpoint
  #   @see https://developer.mautic.org/#endpoints
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

    class Attribute < OpenStruct

      def name
        @alias
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

    attr_reader :connection
    attr_accessor :errors
    attr_writer :changed

    # @param [Mautic::Connection] connection
    def initialize(connection, hash = nil)
      @connection = connection
      @table = MauticHash.new
      self.attributes = { id: hash['id'], created_at: hash['dateAdded']&.to_time, updated_at: hash['dateModified']&.to_time } if hash
      assign_attributes(hash)
      clear_changes
    end

    def mautic_id
      "#{id}/#{@connection.id}"
    end

    def save(force = false)
      id.present? ? update(force) : create
    end

    def update(force = false)
      return false unless changed?

      begin
        json = @connection.request((force && :put || :patch), "api/#{endpoint}/#{id}/edit", body: to_mautic)
        assign_attributes json[endpoint.singularize]
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      errors.blank?
    end

    def update_columns(attributes = {})
      json = @connection.request(:patch, "api/#{endpoint}/#{id}/edit", body: to_mautic(attributes))
      assign_attributes json[endpoint.singularize]
      clear_changes
    rescue ValidationError => e
      self.errors = e.errors
    end

    def create
      begin
        json = @connection.request(:post, "api/#{endpoint}/#{id && "#{id}/"}new", body: to_mautic)
        assign_attributes json[endpoint.singularize]
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      errors.blank?
    end

    def destroy
      begin
        @connection.request(:delete, "api/#{endpoint}/#{id}/delete")
        true
      rescue RequestError => e
        self.errors = e.errors
        false
      end
    end

    def changes
      @table.changes
    end

    def changed?
      return @changed unless @changed.nil?

      @changed = !changes.empty?
    end

    def attributes
      @table.to_h
    end

    def attributes=(hash)
      hash.each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
      end
    end

    def to_mautic(data = @table)
      data.each_with_object({}) do |(key, val), mem|
        mem[key] = if val.respond_to?(:to_mautic)
                     val.to_mautic
                   elsif val.is_a?(Array)
                     val.join("|")
                   else
                     val
                   end
      end
    end

    private

    def clear_changes
      @changed = nil
      @table.instance_variable_set(:@changes, nil)
    end

    def endpoint
      self.class.endpoint
    end

    def assign_attributes(source = nil)
      @mautic_attributes = []
      source ||= {}

      data = if (fields = source['fields'])
               attributes_from_fields(fields)
             elsif source
               source
             end
      self.attributes = data
    end

    def attributes_from_fields(fields)
      data = {}
      if fields['all']
        @mautic_attributes = fields['all'].collect do |key, value|
          data[key] = value
          Attribute.new(alias: key, value: value)
        end
      else
        fields.each do |_group, pairs|
          next unless pairs.is_a?(Hash)

          pairs.each do |key, attrs|
            @mautic_attributes << (a = Attribute.new(attrs))
            data[key] = a.value
          end
        end
      end

      data
    end

  end
end
