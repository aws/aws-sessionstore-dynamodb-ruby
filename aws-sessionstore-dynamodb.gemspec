require File.dirname(__FILE__) + '/lib/aws/session_store/dynamo_db/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-sessionstore-dynamodb"
  spec.version       = Aws::SessionStore::DynamoDB::VERSION
  spec.authors       = ["Ruby Robinson"]
  spec.summary       = "The Amazon DynamoDB Session Store handles sessions " +
                       "for Ruby web applications using a DynamoDB backend."
  spec.homepage      = "http://github.com/aws/aws-sessionstore-dynamodb-ruby"
  spec.license       = "Apache License 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 3'
  spec.add_dependency 'rack', '>= 1.6.4'
end
