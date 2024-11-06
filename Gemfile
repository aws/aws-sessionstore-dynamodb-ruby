# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'json', '2.7.5' if defined?(JRUBY_VERSION) #temporary

gem 'rake', require: false

group :development do
  gem 'byebug', platforms: :ruby
  gem 'rubocop'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end

group :test do
  gem 'rack-test'
  gem 'rails'
  gem 'rexml'
  gem 'rspec'
  gem 'simplecov'
end
