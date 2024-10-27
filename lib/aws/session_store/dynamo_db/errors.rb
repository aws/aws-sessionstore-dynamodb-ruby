# frozen_string_literal: true

module Aws::SessionStore::DynamoDB::Errors
  # This error is raised when no secret key is provided.
  class MissingSecretKeyError < RuntimeError
    def initialize(msg = 'No secret key provided!')
      super
    end
  end

  # This error is raised when an invalid session ID is provided.
  class InvalidIDError < RuntimeError
    def initialize(msg = 'Corrupt Session ID!')
      super
    end
  end

  # This error is raised when the maximum time spent to acquire lock has been exceeded.
  class LockWaitTimeoutError < RuntimeError
    def initialize(msg = 'Maximum time spent to acquire lock has been exceeded!')
      super
    end
  end
end

require_relative 'errors/base_handler'
require_relative 'errors/default_handler'
