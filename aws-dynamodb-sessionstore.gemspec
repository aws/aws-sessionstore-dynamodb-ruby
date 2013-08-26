Gem::Specification.new do |spec|
  spec.name          = "aws-dynamodb-sessionstore"
  spec.version       = "0.5.0"
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
