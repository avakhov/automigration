require 'rails/engine'
require 'automigration/version'
require 'automigration/migrator'
require 'automigration/fields/sys/base'
require 'automigration/fields/belongs_to'
require 'automigration/fields/boolean'
require 'automigration/fields/date'
require 'automigration/fields/datetime'
require 'automigration/fields/float'
require 'automigration/fields/integer'
require 'automigration/fields/password'
require 'automigration/fields/string'
require 'automigration/fields/text'
require 'automigration/fields/time'
require 'automigration/fields/sys/db_column'
require 'automigration/fields/sys/keeper'
require 'automigration/fields/sys/slice_creater'

module Automigration
  class Engine < ::Rails::Engine
    config.automigration = ActiveSupport::OrderedOptions.new
    config.automigration.system_tables = []
    config.automigration.models_load_path = []
    config.automigration.models_to_ignore = []
    config.automigration.migrations_path = nil

    initializer 'automigration' do |app|
      app.config.automigration.models_load_path << Rails.root + 'app/models'
      app.config.automigration.migrations_path = Rails.root + 'db/migrate'

      ActiveSupport.on_load(:active_record) do
        require 'automigration/base_extention'
      end

      Migrator.set_models_load_path(app.config.automigration.models_load_path)
      Migrator.set_models_to_ignore(app.config.automigration.models_to_ignore)
      Migrator.set_system_tables(app.config.automigration.system_tables)
      Migrator.set_migrations_path(app.config.automigration.migrations_path)
    end
  end
end
