require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

namespace :db do
  desc 'Recreate test db'
  task :prepare do
    `dropdb automigration_test`
    `createdb automigration_test`
  end
end

