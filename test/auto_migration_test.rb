require 'test_helper'

module Automigration
  class AutoMigrationTest < ActiveSupport::TestCase
    def setup
      @migrations_path = Migrator.migrations_path
      @system_tables = Migrator.system_tables
      @models_to_ignore = Migrator.models_to_ignore
    end

    def teardown
      Migrator.set_migrations_path(@migrations_path)
      Migrator.set_system_tables(@system_tables)
      Migrator.set_models_to_ignore(@models_to_ignore)

      if connection.table_exists?('not_used_table')
        connection.drop_table('not_used_table')
      end

      if connection.table_exists?('schema_migrations')
        connection.drop_table('schema_migrations')
      end

      FileUtils.rm_rf(migrations_dir)

      connection.drop_table('auto_migration1s') if Migrator.all_tables.index('auto_migration1s')
      connection.drop_table('auto_migration2s')
      Migrator.new(:skip_output => true).update_schema!
    end

    def test_create_table_if_need
      connection.drop_table('auto_migration1s')
      assert !Migrator.all_tables.index('auto_migration1s')

      Migrator.new(:skip_output => true).update_schema!
      assert Migrator.all_tables.index('auto_migration1s')
    end

    def test_not_create_table_if_ignored
      connection.drop_table('auto_migration1s')
      assert !Migrator.all_tables.index('auto_migration1s')

      Migrator.set_models_to_ignore(['auto_migration1'])
      Migrator.new(:skip_output => true).update_schema!
      assert !Migrator.all_tables.index('auto_migration1s')
    end

    def test_remove_unused_table
      connection.create_table('not_used_table')
      assert Migrator.all_tables.index('not_used_table')

      Migrator.new(:skip_output => true).update_schema!
      assert !Migrator.all_tables.index('not_used_table')
    end

    def test_not_remove_unused_table_if_it_checked_as_not_migratable
      connection.create_table('not_used_table')
      Migrator.set_system_tables(%w(not_used_table))
      assert Migrator.all_tables.index('not_used_table')

      Migrator.new(:skip_output => true).update_schema!
      assert Migrator.all_tables.index('not_used_table')
    end

    def test_clean_unused_migration
      connection.create_table('schema_migrations') do |t|
        t.string :version
      end
      connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114120000')")
      connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114132500')")
      connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114193000')")

      FileUtils.mkdir_p(migrations_dir)
      File.open(migrations_dir + "/20110114120000_create_users.rb", "w"){|f| f.puts "# some text"}
      File.open(migrations_dir + "/20110114193000_create_projects.rb", "w"){|f| f.puts "# some text"}

      Migrator.set_migrations_path(migrations_dir)

      count_sql = "SELECT count(*) AS count FROM schema_migrations"
      assert_equal 3, connection.execute(count_sql)[0]['count'].to_i
      Migrator.new(:skip_output => true).update_schema!
      assert_equal 2, connection.execute(count_sql)[0]['count'].to_i
    end
    
    def test_update_column_for_model_not_change_type_dramatically
      connection.remove_column(AutoMigration1.table_name, 'string_field')
      connection.add_column(AutoMigration1.table_name, 'string_field', :integer)
      AutoMigration1.reset_column_information

      AutoMigration1.create!(:string_field => 123)
      assert_equal 123, AutoMigration1.first.string_field

      Migrator.new(:skip_output => true).update_schema!

      assert_equal '123', AutoMigration1.first.string_field
    end

    def test_update_column_for_model_change_type_dramatically
      connection.remove_column(AutoMigration1.table_name, 'integer_field')
      connection.add_column(AutoMigration1.table_name, 'integer_field', :string)
      AutoMigration1.reset_column_information

      AutoMigration1.create!(:integer_field => 'abc')
      assert_equal 'abc', AutoMigration1.first.integer_field

      Migrator.new(:skip_output => true).update_schema!

      assert_equal nil, AutoMigration1.first.integer_field
    end

    def test_create_columns_for_model
      assert AutoMigration1.new.attributes.keys.index("boolean_field")
      assert AutoMigration1.new.attributes.keys.index("integer_field")
      assert AutoMigration1.new.attributes.keys.index("float_field")
      assert AutoMigration1.new.attributes.keys.index("string_field")
      assert AutoMigration1.new.attributes.keys.index("text_field")
      assert AutoMigration1.new.attributes.keys.index("datetime_field")
      assert AutoMigration1.new.attributes.keys.index("date_field")
      assert AutoMigration1.new.attributes.keys.index("time_field")
      assert AutoMigration1.new.attributes.keys.index("additional_field")

      assert AutoMigration1.new.attributes.keys.index("created_at")
      assert AutoMigration1.new.attributes.keys.index("updated_at")
    end

    def test_create_columns_for_model_add_field
      assert AutoMigration1a.new.attributes.keys.index("additional_field")
      assert AutoMigration1a.new.attributes.keys.index("integer_field")

      assert AutoMigration1a.new.attributes.keys.index("created_at")
      assert AutoMigration1a.new.attributes.keys.index("updated_at")
    end

    def test_create_model_without_timestamps
      assert !AutoMigration3.new.attributes.keys.index("created_at")
      assert !AutoMigration3.new.attributes.keys.index("updated_at")
    end

    def test_destroy_columns_for_model
      connection.add_column(AutoMigration1.table_name, 'new_column', :string)
      AutoMigration1.reset_column_information

      assert AutoMigration1.column_names.index('new_column')
      Migrator.new(:skip_output => true).update_schema!
      assert !AutoMigration1.column_names.index('new_column')
    end

    def test_destroy_columns_for_model
      connection.add_column(AutoMigration1.table_name, 'new_column', :string)
      AutoMigration1.reset_column_information

      assert AutoMigration1.column_names.index('new_column')
      Migrator.new(:skip_output => true).update_schema!
      assert !AutoMigration1.column_names.index('new_column')
    end

    def test_destroy_columns_for_model_if_they_are_not_migrate_attr
      connection.add_column(AutoMigration2.table_name, 'some_attr1', :string)
      connection.add_column(AutoMigration2.table_name, 'some_attr2', :string)
      connection.add_column(AutoMigration2.table_name, 'some_attr3', :string)
      connection.add_column(AutoMigration2.table_name, 'some_attr4', :string)
      AutoMigration2.reset_column_information

      assert AutoMigration2.column_names.index('some_attr1')
      assert AutoMigration2.column_names.index('some_attr2')
      assert AutoMigration2.column_names.index('some_attr3')
      assert AutoMigration2.column_names.index('some_attr4')

      Migrator.new(:skip_output => true).update_schema!

      assert AutoMigration2.column_names.index('some_attr1')
      assert AutoMigration2.column_names.index('some_attr2')
      assert AutoMigration2.column_names.index('some_attr3')
      assert !AutoMigration2.column_names.index('some_attr4')
    end

    private
    def migrations_dir
      File.expand_path("../../../tmp/migrations", __FILE__)
    end
      
    def connection
      ActiveRecord::Base.connection
    end
  end
end
