require "oauth2"
require "mautic/engine"

module Mautic
  include ::ActiveSupport::Configurable

  autoload :FormHelper, 'mautic/form_helper'
  autoload :Proxy, 'mautic/proxy'
  autoload :Model, 'mautic/model'
  autoload :Submissions, 'mautic/submissions'

  class RequestError < StandardError

    attr_reader :response, :errors

    def initialize(response, message = nil)
      @errors ||= []
      @response = response
      json_body = JSON.parse(response.body) rescue {}
      message ||= Array(json_body['errors']).collect do |error|
        msg = error['code'].to_s
        msg << " (#{error['type']}):" if error['type']
        msg << " #{error['message']}"
        @errors << error['message']
        msg
      end.join(', ')

      super(message)
    end

  end

  class TokenExpiredError < RequestError
  end

  class ValidationError < RequestError

    def initialize(response, message = nil)
      @response = response
      json_body = JSON.parse(response.body) rescue {}
      @errors = Array(json_body['errors']).inject({}) { |mem, var| mem.merge!(var['details']); mem }
      message ||= @errors.collect { |field, msg| "#{field}: #{msg.join(', ')}" }.join('; ')
      super(response, message)
    end

  end

  class AuthorizeError < RequestError
  end

  class RecordNotFound < RequestError
  end

  configure do |config|
    # This is URL your application - its for oauth callbacks
    config.base_url = "http://localhost:3000"
    # *optional* This is your default mautic URL - used in form helper
    config.mautic_url = "https://mautic.my.app"
  end
  # Your code goes here...

  if Rails.version.start_with? "4"
    class DummyMigrationClass < ActiveRecord::Migration
    end
  else
    class DummyMigrationClass < ActiveRecord::Migration[4.2]
    end
  end

end
