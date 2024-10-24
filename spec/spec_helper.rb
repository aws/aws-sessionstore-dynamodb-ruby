# frozen_string_literal: true

require 'simplecov'
SimpleCov.start { add_filter 'spec' }

$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'lib')

require 'rack/test'
require 'rspec'
require 'aws-sessionstore-dynamodb'

# Default Rack application
class MultiplierApplication
  def call(env)
    if env['rack.session'][:multiplier]
      env['rack.session'][:multiplier] *= 2
    else
      env['rack.session'][:multiplier] = 1
    end
    [200, { 'Content-Type' => 'text/plain' }, ['All good!']]
  end
end

RSpec.configure do |c|
  c.before(:all, integration: true) do
    opts = { table_name: 'sessionstore-integration-test' }
    Aws::SessionStore::DynamoDB::Table.create_table(opts)
  end
end
