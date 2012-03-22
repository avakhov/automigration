require 'spec_helper'

describe 'automigration' do
  let(:migrations_dir) { File.expand_path("../../../tmp/migrations", __FILE__) }
  let(:connection) { ActiveRecord::Base.connection }

  before do
    @migration_paths = Automigration::Migrator.migration_paths
    @system_tables = Automigration::Migrator.system_tables
  end

  after do
    Automigration::Migrator.set_migration_paths(@migration_paths)
    Automigration::Migrator.set_system_tables(@system_tables)

    if connection.table_exists?('not_used_table')
      connection.drop_table('not_used_table')
    end

    if connection.table_exists?('schema_migrations')
      connection.execute('DELETE FROM schema_migrations')
    end

    FileUtils.rm_rf(migrations_dir)

    if ActiveRecord::Base.connection.tables.index('auto_migration1s')
      connection.drop_table('auto_migration1s')
    end

    connection.drop_table('auto_migration2s')
    Automigration::Migrator.new(:skip_output => true).update_schema!
  end

  it 'create_table_if_need' do
    connection.drop_table('auto_migration1s')
    ActiveRecord::Base.connection.tables.index('auto_migration1s').should be_nil

    Automigration::Migrator.new(:skip_output => true).update_schema!
    ActiveRecord::Base.connection.tables.index('auto_migration1s').should_not be_nil
  end

  it 'remove_unused_table' do
    connection.create_table('not_used_table')
    ActiveRecord::Base.connection.tables.index('not_used_table').should_not be_nil

    Automigration::Migrator.new(:skip_output => true).update_schema!
    ActiveRecord::Base.connection.tables.index('not_used_table').should be_nil
  end

  it 'not_remove_unused_table_if_it_checked_as_not_migratable' do
    connection.create_table('not_used_table')
    Automigration::Migrator.set_system_tables(%w(not_used_table))
    ActiveRecord::Base.connection.tables.index('not_used_table').should_not be_nil

    Automigration::Migrator.new(:skip_output => true).update_schema!
    ActiveRecord::Base.connection.tables.index('not_used_table').should_not be_nil
  end

  it 'clean_unused_migration' do
    connection.execute('DELETE FROM schema_migrations')
    connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114120000')")
    connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114132500')")
    connection.execute("INSERT INTO schema_migrations(version) VALUES('20110114193000')")

    FileUtils.mkdir_p(migrations_dir)
    File.open(migrations_dir + "/20110114120000_create_users.rb", "w"){|f| f.puts "# some text"}
    File.open(migrations_dir + "/20110114193000_create_projects.rb", "w"){|f| f.puts "# some text"}

    Automigration::Migrator.set_migration_paths([migrations_dir])

    count_sql = "SELECT count(*) AS count FROM schema_migrations"
    connection.execute(count_sql)[0]['count'].to_i.should == 3
    Automigration::Migrator.new(:skip_output => true).update_schema!
    connection.execute(count_sql)[0]['count'].to_i.should == 2
  end
  
  it 'update_column_for_model_not_change_type_dramatically' do
    connection.remove_column(AutoMigration1.table_name, 'string_field')
    connection.add_column(AutoMigration1.table_name, 'string_field', :integer)
    AutoMigration1.reset_column_information

    AutoMigration1.create!(:string_field => 123)
    AutoMigration1.first.string_field.should == 123

    Automigration::Migrator.new(:skip_output => true).update_schema!

    AutoMigration1.first.string_field.should == '123'
  end

  it 'create_columns_for_model' do
    AutoMigration1.new.attributes.keys.index("boolean_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("integer_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("float_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("string_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("text_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("datetime_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("date_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("time_field").should_not be_nil
    AutoMigration1.new.attributes.keys.index("additional_field").should_not be_nil

    AutoMigration1.new.attributes.keys.index("created_at").should_not be_nil
    AutoMigration1.new.attributes.keys.index("updated_at").should_not be_nil
  end

  it 'create_columns_for_model_add_field' do
    AutoMigration1a.new.attributes.keys.index("additional_field").should_not be_nil
    AutoMigration1a.new.attributes.keys.index("integer_field").should_not be_nil

    AutoMigration1a.new.attributes.keys.index("created_at").should_not be_nil
    AutoMigration1a.new.attributes.keys.index("updated_at").should_not be_nil
  end

  it 'create_model_without_timestamps' do
    AutoMigration3.new.attributes.keys.index("created_at").should be_nil
    AutoMigration3.new.attributes.keys.index("updated_at").should be_nil
  end

  it 'destroy_columns_for_model' do
    connection.add_column(AutoMigration1.table_name, 'new_column', :string)
    AutoMigration1.reset_column_information

    AutoMigration1.column_names.index('new_column').should_not be_nil
    Automigration::Migrator.new(:skip_output => true).update_schema!
    AutoMigration1.column_names.index('new_column').should be_nil
  end

  it 'destroy_columns_for_model' do
    connection.add_column(AutoMigration1.table_name, 'new_column', :string)
    AutoMigration1.reset_column_information

    AutoMigration1.column_names.index('new_column').should_not be_nil
    Automigration::Migrator.new(:skip_output => true).update_schema!
    AutoMigration1.column_names.index('new_column').should be_nil
  end

  it 'destroy_columns_for_model_if_they_are_not_migrate_attr' do
    connection.add_column(AutoMigration2.table_name, 'some_attr1', :string)
    connection.add_column(AutoMigration2.table_name, 'some_attr2', :string)
    connection.add_column(AutoMigration2.table_name, 'some_attr3', :string)
    connection.add_column(AutoMigration2.table_name, 'some_attr4', :string)
    AutoMigration2.reset_column_information

    AutoMigration2.column_names.index('some_attr1').should_not be_nil
    AutoMigration2.column_names.index('some_attr2').should_not be_nil
    AutoMigration2.column_names.index('some_attr3').should_not be_nil
    AutoMigration2.column_names.index('some_attr4').should_not be_nil

    Automigration::Migrator.new(:skip_output => true).update_schema!

    AutoMigration2.column_names.index('some_attr1').should_not be_nil
    AutoMigration2.column_names.index('some_attr2').should_not be_nil
    AutoMigration2.column_names.index('some_attr3').should_not be_nil
    AutoMigration2.column_names.index('some_attr4').should be_nil
  end
end
