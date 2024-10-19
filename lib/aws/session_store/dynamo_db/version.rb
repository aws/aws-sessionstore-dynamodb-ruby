# frozen_string_literal: true

module Aws
  module SessionStore
    module DynamoDB
      VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
    end
  end
end
