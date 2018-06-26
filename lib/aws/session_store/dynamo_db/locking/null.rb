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


module Aws::SessionStore::DynamoDB::Locking
  # This class gets and sets sessions
  # without a locking strategy.
  class Null < Aws::SessionStore::DynamoDB::Locking::Base
    # Retrieve session if it exists from the database by id.
    # Unpack the data once retrieved from the database.
    def get_session_data(env, sid)
      handle_error(env) do
        result = @config.dynamo_db_client.get_item(get_session_opts(sid))
        extract_data(env, result)
      end
    end

    # @return [Hash] Options for getting session.
    def get_session_opts(sid)
      merge_all(table_opts(sid), attr_opts)
    end

    # @return [String] Session data.
    def extract_data(env, result = nil)
      env['rack.initial_data'] = result[:item]["data"] if result[:item]
      unpack_data(result[:item]["data"]) if result[:item] && result[:item].has_key?("data")
    end

  end
end
