require 'spec_helper'

describe 'fields' do
  it 'kind_of_field' do
    assert_equal :boolean, Automigration::Fields::Boolean.kind
  end

  it 'automigrable_model' do
    assert Simple.fields_keeper.auto_migrable?
    assert !NotAutomigrable.fields_keeper.auto_migrable?
  end

  it 'migrations_attrs' do
    assert_equal [], AutoMigration1.fields_keeper.migration_attrs

    assert_equal ['some_attr1', 'some_attr2' , 'some_attr3'], 
      AutoMigration2.fields_keeper.migration_attrs
  end

  it 'boolean_column_false_by_default' do
    assert_equal false, AutoMigration1.new.boolean_field
  end

  it 'from_meta' do
    assert_equal Automigration::Fields::Boolean, Automigration::Fields::Sys::Base.from_meta(:as => :boolean, :name => 'some').class
  end

  it 'attributes_accessible' do
    obj = AutoMigration1.create(:integer_field => 123)
    assert_equal 123, obj.integer_field
  end
end
