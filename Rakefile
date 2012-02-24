require 'bundler/setup'
require 'rake/clean'
require 'rake/testtask'
require 'rspec/core/rake_task'

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

Dir['rake/**/*.rake'].each {|f| import f }

Bundler::GemHelper.install_tasks
task :build => :gemspec
task :install => :gemspec

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do
end

desc "Generate code coverage"
task :coverage do
  require 'simplecov'
  SimpleCov.start

  Rake::Task[:spec].invoke
end

task :test => :spec
task :default => :spec