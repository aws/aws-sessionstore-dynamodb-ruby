source 'https://rubygems.org'

gemspec

gem 'rake', require: false

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :test do
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'rack-test'

  if RUBY_VERSION >= '3.0'
    gem 'rexml'
  end
end
