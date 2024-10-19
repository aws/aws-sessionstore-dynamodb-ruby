# frozen_string_literal: true

module Aws::SessionStore::DynamoDB
  # This error is raised when an invalid session ID is provided.
  class InvalidIDError < RuntimeError
    def initialize(msg = 'Corrupt Session ID!')
      super
    end
  end
end
