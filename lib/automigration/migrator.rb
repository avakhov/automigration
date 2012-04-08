module Automigration
  class Migrator
    mattr_reader :system_tables
    mattr_reader :migration_paths
    mattr_reader :model_paths
    @@system_tables = []
    @@migration_paths = []
    @@model_paths = []

    def self.set_system_tables(tables)
      @@system_tables = tables
    end

    def self.set_migration_paths(paths)
      @@migration_paths = paths
    end

    def self.set_model_paths(paths)
      @@model_paths = paths
    end

    def self.load_all_models!
      @@model_paths.each do |path|
        Dir[File.expand_path("**/*.rb", path)].each do |file|
          name = file.sub(path.to_s + '/', '').sub(Regexp.new(File.extname(file) + '$'), '')
          ActiveSupport::Dependencies.constantize(name.classify)
        end
      end
    end

    def initialize(options = {})
      options.assert_valid_keys(:skip_output, :models)

      self.class.load_all_models!

      @models = options[:models] || ActiveRecord::Base.descendants
      @options = options
    end

    def update_schema!
      log "Models: " + @models.map(&:to_s).join(', ')

      # update tables
      tables = ['schema_migrations']
      @models.each do |model|
        update_model_schema(model)
        tables << model.table_name
      end

      #remove unused tables
      (connection.tables - tables - @@system_tables).each do |table|
        connection.drop_table(table)
        log "Remove table '#{table}'", :red
      end

      # clean migration table
      if connection.table_exists?('schema_migrations') && !@@migration_paths.empty?
        sql = "SELECT version FROM schema_migrations;"

        migrations_in_db = connection.execute(sql).map{|row| row['version']}
        current_migrations = []
        @@migration_paths.each do |path|
          Dir[File.expand_path("*.rb", path)].each do |m_file| 
            File.basename(m_file) =~ /(\d{14})/
            current_migrations << $1
          end
        end

        (migrations_in_db - current_migrations).each do |m|
          log "Clean migration '#{m}'", :red
          sql = "DELETE FROM schema_migrations WHERE version = '#{m}';"
          connection.execute(sql)
        end
      end
    end

    private

    def update_model_schema(model)
      # 0. Create table if need
      unless connection.table_exists?(model.table_name)
        connection.create_table(model.table_name) {}
        log "Create table #{model.table_name}", :green
        model.reset_column_information
      end

      unless model.auto_migrable?
        log "#{model.to_s} skipped", :yellow
      else
        log "process #{model.to_s} ..."
        auto_columns = model.field_db_columns
        auto_columns_names = auto_columns.map{|c| c.name.to_s}
        auto_columns_hash = Hash[auto_columns.map{|c| [c.name.to_s, c]}]

        # 1. update columns
        (model.column_names & auto_columns_names).each do |name|
          model_column = Automigration::DbColumn.from_activerecord_column(model.columns_hash[name])
          auto_column = auto_columns_hash[name]

          unless model_column.the_same?(auto_column)
            begin
              connection.change_column(model.table_name, name, auto_column.type, auto_column.to_options)

              log "Update column #{name} of #{model.table_name} " + 
                "to :#{auto_column.type} type and options #{auto_column.to_options.inspect}", :yellow
            rescue
              connection.remove_column(model.table_name, name)
              connection.add_column(model.table_name, name, auto_column.type, auto_column.to_options)
              log "recreate column #{name} in #{model.table_name}", :yellow
            end
          end
        end

        # 2. add new columns
        (auto_columns_names - model.column_names).each do |name|
          auto_column = auto_columns_hash[name]
          connection.add_column(model.table_name, name, auto_column.type, auto_column.to_options)
          log "Add column #{name} to #{model.table_name}", :green

          model.reset_column_information

          if auto_column.options[:default].present?
            model.update_all("#{name} = '#{auto_column.options[:default]}'")
            log "Update default value for #{model.count} models", :green
          end
        end

        # 3. remove obsoleted columns
        not_to_del = ['id'] + model.migration_attrs
        (model.column_names - auto_columns_names - not_to_del).each do |name|
          connection.remove_column(model.table_name, name)
          log "Remove column #{name} from #{model.table_name}", :red
        end

        model.reset_column_information
      end
    end

    def connection
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
