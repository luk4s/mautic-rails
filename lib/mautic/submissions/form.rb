module Mautic
  module Submissions
    # @see https://developer.mautic.org/#get-form-submissions
    class Form
      attr_reader :id

      # @param [Mautic::Connection] connection
      # @param [Hash] data
      def initialize(connection, data)
        @connection = connection
        @raw = data
        @id = data["id"].to_i
      end

      # @return [Integer]
      def form_id
        @form_id ||= @raw["form"]["id"].to_i
      end

      # @return [Integer]
      def contact_id
        @contact_id ||= @raw["lead"]["id"]
      end

      # @return [Mautic::Form]
      def form
        @form ||= @connection.forms.new(@raw["form"].merge("fields" => @raw["results"]))
      end

      # @return [Mautic::Contact]
      def contact
        @contact ||= @connection.contacts.new(@raw["lead"])
      end

      # @return [Hash]
      def ip_details
        ip_address["ipDetails"] || {}
      end

      # @return [Hash]
      def ip_address
        @raw["ipAddress"] || {}
      end

      # @return [String]
      def referer
        @raw["referer"].to_s
      end

      # @return [Hash]
      def results
        @raw["results"]
      end

    end
  end
end
