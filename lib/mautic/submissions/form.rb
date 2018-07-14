module Mautic
  module Submissions
    class Form
      attr_reader :id

      def initialize(connection, data)
        @connection = connection
        @raw = data
        @id = data["id"]
      end

      def form_id
        @raw["form"]["id"]
      end

      def contact_id
        @raw["lead"]["id"]
      end

      def form
        @form ||= @connection.forms.new(@raw["form"].merge("fields" => @raw["results"]))
      end

      def contact
        @connection.contacts.new(@raw["lead"])
      end
    end
  end
end