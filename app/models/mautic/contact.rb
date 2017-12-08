module Mautic
  class Contact < Model

    def self.in(connection)
      Proxy.new(connection, endpoint, default_params: { search: '!is:anonymous' })
    end

    def name
      "#{firstname} #{lastname}"
    end

    def first_name= arg
      self.firstname = arg
    end

    def last_name= arg
      self.lastname = arg
    end

  end
end