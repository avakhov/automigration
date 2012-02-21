module Automigration
  class Migrator
    mattr_reader :system_tables
    mattr_reader :migrations_path
    mattr_reader :models_load_path
    mattr_reader :models_to_ignore
    @@system_tables = []
    @@migrations_path = nil
    @@models_load_path = []
    @@models_to_ignore = []

    def self.set_system_tables(tables)
      @@system_tables = tables
    end

    def self.set_migrations_path(path)
      @@migrations_path = path
    end

    def self.set_models_load_path(paths)
      @@models_load_path = paths
    end

    def self.set_models_to_ignore(models)
      @@models_to_ignore = models
    end

    def self.all_tables
      sql = "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
      ActiveRecord::Base.connection.execute(sql).map do |row|
        row["tablename"]
      end
    end

    def self.get_models
      @@models_load_path.map do |path|
        Dir[File.expand_path("**/*.rb", path)].map do |model_file|
          model_name = model_file.sub(path.to_s + '/', '').sub(/.rb$/, '')
          next if @@models_to_ignore.include?(model_name)
          model = model_name.camelize.constantize
          if model && model.superclass == ActiveRecord::Base
            model
          end
        end
      end.flatten.compact
    end

    def initialize(options = {})
      options.assert_valid_keys(:skip_output, :models)

      @models = options[:models] || self.class.get_models
      @options = options
    end

    def update_schema!
      log "Models: " + @models.map(&:to_s).join(', ')

      # update tables
      tables = ['schema_migrations']
      @models.each do |model|
        update_model_schema(model)
        tables << model.table_name

        # update globalize2 tables
        if model.respond_to?(:translated_attribute_names)
          translated_model = translated_model(model)
          update_model_schema(translated_model)
          tables << translated_model.table_name
        end
      end

      #remove unused tables
      (self.class.all_tables - tables - @@system_tables).each do |table|
        con.drop_table(table)
        log "Remove table '#{table}'", :red
      end

      # clean migration table
      if con.table_exists?('schema_migrations') and @@migrations_path
        sql = "SELECT version FROM schema_migrations;"

        migrations_in_db = con.execute(sql).map{|row| row['version']}
        current_migrations = Dir[File.expand_path("*.rb", @@migrations_path)].map do |m_file| 
          File.basename(m_file) =~ /(\d{14})/
          $1
        end

        (migrations_in_db - current_migrations).each do |m|
          log "Clean migration '#{m}'", :red
          sql = "DELETE FROM schema_migrations WHERE version = '#{m}';"
          con.execute(sql)
        end
      end
    end

    private
    def get_all_models
      out = []
      Dir[Rails.root + "app/models/**/*.rb"].sort.each do |model_file|
        model_name = model_file.sub((Rails.root + "app/models/").to_s, '').sub(/.rb$/, '')
        model = model_name.camelize.constantize
        if model && model.superclass == ActiveRecord::Base
          out << model
        end
      end
      out
    end

    def translated_model(model)
      Class.new(ActiveRecord::Base).tap do |out|
        out.set_table_name((model.model_name.underscore + '_translation').pluralize)

        out.has_fields do |f|
          f.integer "#{model.table_name.singularize}_id"
          f.string :locale
          model.translated_attribute_names.each do |attr_name|
            model.fields_keeper.db_columns_for_field(attr_name).each do |column|
              f.send column.type, column.name
            end
          end
        end
      end
    end

    def update_model_schema(model)
      # 0. Create table if need
      unless con.table_exists?(model.table_name)
        con.create_table(model.table_name) {}
        log "Create table #{model.table_name}", :green
        model.reset_column_information
      end

      unless model.fields_keeper.auto_migrable?
        log "#{model.to_s} skipped", :yellow
      else
        log "process #{model.to_s} ..."
        auto_columns = model.fields_keeper.db_columns
        auto_columns_names = auto_columns.map{|c| c.name.to_s}
        auto_columns_hash = Hash[auto_columns.map{|c| [c.name.to_s, c]}]

        # 1. update columns
        (model.column_names & auto_columns_names).each do |name|
          model_column = Fields::Sys::DbColumn.from_activerecord_column(model.columns_hash[name])
          auto_column = auto_columns_hash[name]

          unless model_column.the_same?(auto_column)
            begin
              con.change_column(model.table_name, name, auto_column.type, auto_column.to_options)

              log "Update column #{name} of #{model.table_name} " + 
                "to :#{auto_column.type} type and options #{auto_column.to_options.inspect}", :yellow
            rescue
              con.remove_column(model.table_name, name)
              con.add_column(model.table_name, name, auto_column.type, auto_column.to_options)
              log "recreate column #{name} in #{model.table_name}", :yellow
            end
          end
        end

        # 2. add new columns
        (auto_columns_names - model.column_names).each do |name|
          auto_column = auto_columns_hash[name]
          con.add_column(model.table_name, name, auto_column.type, auto_column.to_options)
          log "Add column #{name} to #{model.table_name}", :green

          model.reset_column_information

          if auto_column.options[:default].present?
            model.update_all("#{name} = '#{auto_column.options[:default]}'")
            log "Update default value for #{model.count} models", :green
          end
        end

        # 3. remove obsoleted columns
        not_to_del = ['id'] + model.fields_keeper.migration_attrs
        (model.column_names - auto_columns_names - not_to_del).each do |name|
          con.remove_column(model.table_name, name)
          log "Remove column #{name} from #{model.table_name}", :red
        end

        model.reset_column_information
      end
    end

    def con
      ActiveRecord::Base.connection
    end

    def log(msg, color = nil)
      puts "[auto] " + colored(msg, color) unless @options[:skip_output]
    end

    def colored(msg, color)
      if [:red, :green, :yellow].include? color
        ANSI.send(color){msg}
      else
        msg
      end
    end
  end
end
