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


module Aws
  module SessionStore
    module DynamoDB; end
  end
end

require 'aws/session_store/dynamo_db/configuration'
require 'aws/session_store/dynamo_db/invalid_id_error'
require 'aws/session_store/dynamo_db/missing_secret_key_error'
require 'aws/session_store/dynamo_db/lock_wait_timeout_error'
require 'aws/session_store/dynamo_db/errors/base_handler'
require 'aws/session_store/dynamo_db/errors/default_handler'
require 'aws/session_store/dynamo_db/garbage_collection'
require 'aws/session_store/dynamo_db/locking/base'
require 'aws/session_store/dynamo_db/locking/null'
require 'aws/session_store/dynamo_db/locking/pessimistic'
require 'aws/session_store/dynamo_db/rack_middleware'
require 'aws/session_store/dynamo_db/table'
require 'aws/session_store/dynamo_db/version'
require 'aws/session_store/dynamo_db/railtie' if defined?(Rails)
