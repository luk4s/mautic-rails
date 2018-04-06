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

    def assign_attributes(source = {})
      data = {}

      fields = source['fields']
      if fields.nil?
        data = source
      elsif fields['all'].nil?
        data = fields.map { |_group, pairs| pairs.map { |key, attrs| [key, attrs['value']] } }.flatten.to_h
      else
        data = fields['all']
      end
      super data
    end
  end
end
