module Mautic
  class Contact < Model

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname
    def self.in(connection)
      Proxy.new(connection, endpoint, default_params: { search: '!is:anonymous' })
    end

    def name
      "#{firstname} #{lastname}"
    end

    def assign_attributes(source = nil)
      super
      self.attributes = {
        tags: (source['tags'] || []).collect { |t| Mautic::Tag.new(@connection, t) }.sort_by(&:name)
      } if source
    end

    def events
      @proxy_events ||= Proxy.new(connection, "contacts/#{id}/events", klass: "Mautic::Event")
    end

  end
end