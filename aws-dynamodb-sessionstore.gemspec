# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/dynamo_db/session_store/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-dynamodb-sessionstore"
  spec.version       = AWS::DynamoDB::SessionStore::VERSION
  spec.authors       = ["Ruby Robinson"]
  spec.summary       = "The Amazon DynamoDB Session Store handles sessions for Ruby web applications using a DynamoDB backend."
  spec.homepage      = "http://github.com/aws/aws-dynamodb-sessionstore-ruby"
  spec.license       = "Apache License 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 1.0'
  spec.add_dependency 'rack', '~> 1.0'
end
