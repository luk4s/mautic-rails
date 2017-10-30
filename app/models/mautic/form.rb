module Mautic
  class Form < Model

    def assign_attributes(source = nil)
      self.attributes = {name: source['name'], fields: source['fields']} if source.is_a? Hash
    end

  end
end