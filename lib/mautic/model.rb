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

    def initialize(proxy, hash=nil)
      @connection = proxy
      @table = MauticHash.new
      if (fields = hash['fields'])
        basic = { created_at: hash['dateAdded']&.to_time, updated_at: hash['dateModified']&.to_time }
        self.attributes = fields['all'].merge(basic)
      elsif hash
        self.attributes = hash
      end
    end

    def save(force = false)
      id.present? ? update(force) : create
    end

    def update(force = false)
      return false if changes.blank?
      json = @proxy.request((force && :put || :patch), "api/#{endpoint}/#{id}/edit", { body: to_h })
      if json['errors']
        self.errors = json['errors']
      else
        self.attributes = json[endpoint.singularize]
      end
      json['errors'].blank?
    end

    def create
      json = @proxy.request(:post, "api/#{endpoint}/#{id}/new", { body: to_h })
      if json['errors']
        self.errors = json['errors']
      else
        self.attributes = json[endpoint.singularize]
      end
      json['errors'].blank?
    end

    def destroy
      json = @proxy.request(:delete, "api/#{endpoint}/#{id}/delete")
      self.errors = json['errors'] if json['errors']
      json['errors'].blank?
    end

    def changes
      @table.changes
    end

    private

    def endpoint
      self.class.name.remove('Mautic').underscore.pluralize
    end

    def attributes=(hash)
      hash.each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
      end
      @table.instance_variable_set(:@changes, nil)
    end

  end
end