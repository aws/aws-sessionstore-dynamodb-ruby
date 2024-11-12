# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name         = 'aws-sessionstore-dynamodb'
  spec.version      = version
  spec.author       = 'Amazon Web Services'
  spec.email        = ['aws-dr-rubygems@amazon.com']
  spec.summary      = 'Amazon DynamoDB Session Store for Rack web applications.'
  spec.description  = 'The Amazon DynamoDB Session Store handles sessions ' \
                      'for Rack web applications using a DynamoDB backend.'
  spec.homepage     = 'https://github.com/aws/aws-sessionstore-dynamodb-ruby'
  spec.license      = 'Apache-2.0'
  spec.files        = Dir['LICENSE', 'CHANGELOG.md', 'VERSION', 'lib/**/*']

  spec.add_dependency 'rack', '~> 3'
  spec.add_dependency 'rack-session', '~> 2'

  # Require 1.85.0 for user_agent_frameworks config
  spec.add_dependency 'aws-sdk-dynamodb', '~> 1', '>= 1.85.0'

  spec.required_ruby_version = '>= 2.7'
end
