# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.


module AWS::SessionStore::DynamoDB::Errors
  # This class handles errors raised from DynamoDB.
  class DefaultHandler < AWS::SessionStore::DynamoDB::Errors::BaseHandler
    # Array of errors that will always be passed up the Rack stack.
    HARD_ERRORS = [
      AWS::DynamoDB::Errors::ResourceNotFoundException,
      AWS::DynamoDB::Errors::ConditionalCheckFailedException,
      AWS::SessionStore::DynamoDB::MissingSecretKeyError,
      AWS::SessionStore::DynamoDB::LockWaitTimeoutError
    ]

    # Determines behavior of DefaultErrorHandler
    # @param [true] raise_errors Pass all errors up the Rack stack.
    def initialize(raise_errors)
      @raise_errors = raise_errors
    end

    # Raises {HARD_ERRORS} up the Rack stack.
    # Places all other errors in Racks error stream.
    def handle_error(error, env = {})
      if HARD_ERRORS.include?(error.class) || @raise_errors
        raise error
      else
        store_error(error, env)
        false
      end
    end

    # Sends error to error stream
    def store_error(error, env = {})
      env["rack.errors"].puts(errors_string(error)) if env
    end

    # Returns string to be placed in error stream
    def errors_string(error)
      str = []
      str << "Exception occurred: #{error.message}"
      str << "Stack trace:"
      str += error.backtrace.map {|l| "  " + l }
      str.join("\n")
    end
  end
end
