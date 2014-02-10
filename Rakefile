require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

Rake::TestTask.new(:test_settings) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_settings.rb'
  test.verbose = true
end

task :default => :test
