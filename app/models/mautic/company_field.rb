module Mautic
  class CompanyField < Model
    def self.endpoint
      "fields/company"
    end

    def self.in(connection)
      Proxy.new(connection, endpoint, klass: name, data_name: "fields")
    end
  end
end
