require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.libs << 'spec/support'
  t.pattern = "spec/**/*_spec.rb"
end

desc "Run tests"
task :default => :test