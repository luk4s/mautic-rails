module Mautic
  class Event < Model

    def initialize(connection, hash = nil)
      hash["id"] ||= hash["eventId"]
      hash["dateAdded"] ||= hash["timestamp"]&.to_time
      super
    end

    def event_label
      eventLabel
    end

    def label
      event_label.is_a?(Hash) && event_label["label"] || event_label.to_s
    end

    def source_url
      event_label.is_a?(Hash) ? "#{connection.url}#{event_label["href"]}" : nil
    end

  end
end
