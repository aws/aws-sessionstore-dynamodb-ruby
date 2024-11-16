# frozen_string_literal: true

module Aws::SessionStore::DynamoDB
  # @api private
  module Locking; end
end

require_relative 'locking/base'
require_relative 'locking/null'
require_relative 'locking/pessimistic'
