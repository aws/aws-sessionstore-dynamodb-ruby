source 'https://rubygems.org'

if ENV['RACK2']
  gem 'rack', '~> 2'
end

gemspec

gem 'rake', require: false

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'simplecov'

  if RUBY_VERSION >= '3.0'
    gem 'rexml'
  end
end
