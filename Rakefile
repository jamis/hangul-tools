require 'rake'
require 'rake/testtask'
require 'rubygems/tasks'

task default: :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

Gem::Tasks.new
