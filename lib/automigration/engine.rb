require 'rails/engine'

module Automigration
  class Engine < ::Rails::Engine
    config.automigration = ActiveSupport::OrderedOptions.new
    config.automigration.system_tables = []
    config.automigration.migration_paths = []
    config.automigration.model_paths = []

    initializer 'automigration' do |app|
      app.config.automigration.migration_paths << Rails.root + 'db/migrate'
      app.config.automigration.model_paths << Rails.root + 'app/models'

      ActiveSupport.on_load(:active_record) do
        require 'automigration/active_record_ext'
      end

      Migrator.set_system_tables(app.config.automigration.system_tables)
      Migrator.set_migration_paths(app.config.automigration.migration_paths)
      Migrator.set_model_paths(app.config.automigration.model_paths)
    end
  end
end
