require 'rubygems'
require 'bundler/setup'
require 'automigration'
require 'test/unit'
require 'rails'
require 'action_controller/railtie'
require 'active_record'

# fake rails application
class AutomigrateApplication < Rails::Application
  config.active_support.deprecation = :log
end
AutomigrateApplication.initialize!

# AR connection
ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'automigration_test',
  :user => ENV['PG_USER']
)

# whitelist attributes
ActiveRecord::Base.attr_accessible nil

# load test models
Dir[File.expand_path("../models/*.rb", __FILE__)].each do |file|
  require file
end

# prepare tables for test models
Automigration::Migrator.set_models_load_path([File.expand_path("../models", __FILE__)])
Automigration::Migrator.all_tables.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end
Automigration::Migrator.new(:skip_output => true).update_schema!
