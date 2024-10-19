# frozen_string_literal: true

module Aws::SessionStore::DynamoDB::Errors
  # This error is raised when no secret key is provided.
  class MissingSecretKeyError < RuntimeError
    def initialize(msg = 'No secret key provided!')
      super
    end
  end
end
