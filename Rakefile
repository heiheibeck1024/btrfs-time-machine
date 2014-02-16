require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

%w[ settings rsync filesystem].each do |t|
  Rake::TestTask.new("test_#{t}".to_s) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = "test/**/test_#{t}.rb"
    test.verbose = true
  end
end

task :default => :test
