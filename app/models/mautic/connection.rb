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

    %w(assets campaigns categories companies emails forms messages notes notifications pages points roles stats users).each do |entity|
      define_method entity do
        Proxy.new(self, entity)
      end
    end

    def contacts
      Proxy.new(self, 'contacts', default_params: { search: '!is:anonymous' })
    end

    def request(type, path, params = {})
      raise NotImplementedError
    end


  end
end
