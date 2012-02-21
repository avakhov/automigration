require 'test_helper'

module Automigration
  class FieldsTest < ActiveSupport::TestCase
    def test_kind_of_field
      assert_equal :boolean, Fields::Boolean.kind
    end

    def test_automigrable_model
      assert Simple.fields_keeper.auto_migrable?
      assert !NotAutomigrable.fields_keeper.auto_migrable?
    end

    def test_migrations_attrs
      assert_equal [], AutoMigration1.fields_keeper.migration_attrs

      assert_equal ['some_attr1', 'some_attr2' , 'some_attr3'], 
        AutoMigration2.fields_keeper.migration_attrs
    end

    def test_boolean_column_false_by_default
      assert_equal false, AutoMigration1.new.boolean_field
    end

    def test_from_meta
      assert_equal Fields::Boolean, Fields::Sys::Base.from_meta(:as => :boolean, :name => 'some').class
    end

    def test_attributes_accessible
      obj = AutoMigration1.create(:integer_field => 123)
      assert_equal 123, obj.integer_field
    end
  end
end
