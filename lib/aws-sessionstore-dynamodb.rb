# frozen_string_literal: true

module Aws
  module SessionStore
    # Namespace for DynamoDB rack session storage.
    module DynamoDB
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end
  end
end

require 'aws/session_store/dynamo_db/configuration'
require 'aws/session_store/dynamo_db/errors/invalid_id_error'
require 'aws/session_store/dynamo_db/errors/missing_secret_key_error'
require 'aws/session_store/dynamo_db/errors/base_handler'
require 'aws/session_store/dynamo_db/errors/default_handler'
require 'aws/session_store/dynamo_db/garbage_collection'
require 'aws/session_store/dynamo_db/rack_middleware'
require 'aws/session_store/dynamo_db/session'
require 'aws/session_store/dynamo_db/table'
