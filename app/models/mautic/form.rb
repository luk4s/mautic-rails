module Mautic
  class Form < Model

    def assign_attributes(source = nil)
      self.attributes = { name: source['name'], fields: source['fields'] } if source.is_a? Hash
    end

    # @param [Integer] submission_id
    # @return Mautic::Submissions::Form
    # @see https://developer.mautic.org/#get-form-submission
    def submission(submission_id)
      json = @connection.request(:get, "api/forms/#{id}/submissions/#{submission_id}")
      Mautic::Submissions::Form.new @connection, json["submission"]
    rescue Mautic::RecordNotFound => _e
      nil
    end

    # @see https://developer.mautic.org/#list-form-submissions
    # @param [Hash] options
    # @option options [String] :search String or search command to filter entities by.
    # @option options [String] :start Starting row for the entities returned. Defaults to 0.
    # @option options [String] :limit Limit number of entities to return. Defaults to the system configuration for pagination (30).
    # @option options [String] :orderBy Column to sort by. Can use any column listed in the response, also can use column of joined table with prefix. Sort by submitted date is s.date_submitted
    # @option options [String] :orderByDir Sort direction: asc or desc.
    # @option options [String] :publishedOnly Only return currently published entities.
    # @option options [String] :minimal Return only array of entities without additional lists in it.
    # @return Array[Mautic::Submissions::Form]
    def submissions(**options)
      json = @connection.request(:get, "api/forms/#{id}/submissions", params: options)
      @submissions = json["submissions"].collect do |attributes|
        Mautic::Submissions::Form.new @connection, attributes
      end
    rescue RequestError => _e
      []
    end

  end
end
