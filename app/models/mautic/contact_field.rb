module Mautic
  class ContactField < Model
    def self.endpoint
      "fields/contact"
    end

    def self.in(connection)
      Proxy.new(connection, endpoint, klass: name, data_name: "fields")
    end
  end
end
