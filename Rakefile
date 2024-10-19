# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join($REPO_ROOT, 'lib'))
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

desc 'Runs unit tests'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib -I #{$REPO_ROOT}/spec --tag ~integration"
  t.pattern = "#{$REPO_ROOT}/spec"
end

desc 'Runs integration tests'
RSpec::Core::RakeTask.new('spec:integration') do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib -I #{$REPO_ROOT}/spec --tag integration"
  t.pattern = "#{$REPO_ROOT}/spec"
end

desc 'Runs unit and integration tests'
task 'test' => [:spec, 'spec:integration']

RuboCop::RakeTask.new

task default: :spec
task 'release:test' => [:spec, 'spec:integration']
