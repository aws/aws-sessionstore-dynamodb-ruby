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
  # BaseErrorHandler provides an interface for error handlers
  # that can be passed in to {AWS::SessionStore::DynamoDB::RackMiddleware}.
  # Each error handler must implement a handle_error method.
  #
  # @example Sample ErrorHandler class
  #   class MyErrorHandler < BaseErrorHandler
  #    # Handles error passed in
  #    def handle_error(e, env = {})
  #      File.open(path_to_file, 'w') {|f| f.write(e.message) }
  #      false
  #    end
  #   end
  class BaseHandler
    # An error and an environment (optionally) will be passed in to
    # this method and it will determine how to deal
    # with the error.
    # Must return false if you have handled the error but are not reraising the
    # error up the stack.
    # You may reraise the error passed.
    #
    # @param [AWS::DynamoDB::Errors::Base] error error passed in from
    #  AWS::SessionStore::DynamoDB::RackMiddleware.
    # @param [Rack::Request::Environment,nil] env Rack environment
    # @return [false] If exception was handled and will not reraise exception.
    # @raise [AWS::DynamoDB::Errors] If error has be reraised.
    def handle_error(error, env = {})
      raise NotImplementedError
    end
  end
end
