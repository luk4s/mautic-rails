module Mautic
  class MauticConnection < ApplicationRecord

    self.table_name = 'mautic_connections'

    validates :url, :client_id, :secret, presence: true
    validates :url, format: URI::regexp(%w(http https))

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


  end
end
