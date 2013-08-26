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


require 'aws/dynamo_db/session_store/configuration'
require 'aws/dynamo_db/session_store/invalid_id_error'
require 'aws/dynamo_db/session_store/missing_secret_key_error'
require 'aws/dynamo_db/session_store/lock_wait_timeout_error'
require 'aws/dynamo_db/session_store/errors/base_handler'
require 'aws/dynamo_db/session_store/errors/default_handler'
require 'aws/dynamo_db/session_store/garbage_collection'
require 'aws/dynamo_db/session_store/locking/base'
require 'aws/dynamo_db/session_store/locking/null'
require 'aws/dynamo_db/session_store/locking/pessimistic'
require 'aws/dynamo_db/session_store/rack_middleware'
require 'aws/dynamo_db/session_store/table'
require 'aws/dynamo_db/session_store/version'
require 'aws/dynamo_db/session_store/railtie' if defined?(Rails)
