module Mautic
  class Connection < ApplicationRecord

    self.table_name = 'mautic_connections'

    validates :url, :client_id, :secret, presence: true
    validates :url, format: URI::regexp(%w(http https))

    alias_attribute :access_token, :token

    def client
      raise NotImplementedError
    end

    def authorize
      raise NotImplementedError
    end

    def get_code(code)
      raise NotImplementedError
    end

    def connection
      raise NotImplementedError
    end

    def refresh!
      raise NotImplementedError
    end

    def contacts
      # .all
      # .first
      # .find
      # .where
      Proxy.new(self, 'contacts')
    end

    # def contact
    #   # .new
    #   # .update
    #   # .create
    #   Proxy.new(self, Mautic::Contact)
    # end


  end
end
