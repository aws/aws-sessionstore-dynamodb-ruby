$REPO_ROOT = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join($REPO_ROOT, 'lib'))
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

require 'rspec/core/rake_task'

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

task 'test:coverage:clear' do
  sh("rm -rf #{File.join($REPO_ROOT, 'coverage')}")
end

# Override the test task definitions
# this package uses rspec tags to define integration tests
Rake::Task["test:unit"].clear
desc 'Runs unit tests'
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib -I #{$REPO_ROOT}/spec --tag ~integration"
  t.pattern = "#{$REPO_ROOT}/spec"
end
task 'test:unit' => 'test:coverage:clear'

Rake::Task["test:integration"].clear
desc 'Runs integration tests'
RSpec::Core::RakeTask.new('test:integration') do |t|
  t.rspec_opts = "-I #{$REPO_ROOT}/lib -I #{$REPO_ROOT}/spec --tag integration"
  t.pattern = "#{$REPO_ROOT}/spec"
end
task 'test:integration' => 'test:coverage:clear'

desc 'Runs unit and integration tests'
task 'test' => ['test:unit', 'test:integration']

task :default => 'test:unit'


