# frozen_string_literal: true

module Aws
  module SessionStore
    # Namespace for DynamoDB rack session storage.
    module DynamoDB
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end
  end
end

require_relative 'aws/session_store/dynamo_db/configuration'
require_relative 'aws/session_store/dynamo_db/errors'
require_relative 'aws/session_store/dynamo_db/garbage_collection'
require_relative 'aws/session_store/dynamo_db/locking'
require_relative 'aws/session_store/dynamo_db/rack_middleware'
require_relative 'aws/session_store/dynamo_db/table'
